use std::io::Write;

use unicode_width::UnicodeWidthStr;

#[derive(Default)]
pub(crate) struct DifferentialOutput {
    width: usize,
    height: usize,
    cells: Vec<Vec<u8>>,
    output: Vec<u8>,
    unsupported: bool,
}

impl DifferentialOutput {
    /// Forget what the terminal shows, so the next frame draws every cell.
    pub(crate) fn invalidate(&mut self) {
        self.cells.iter_mut().for_each(Vec::clear);
    }

    pub(crate) fn frame<'a>(
        &mut self,
        width: usize,
        height: usize,
        prefix: &[u8],
        mut cell: impl FnMut(usize, usize) -> &'a [u8],
    ) -> Option<&[u8]> {
        if self.unsupported {
            return None;
        }
        self.output.clear();
        if (self.width, self.height) != (width, height) {
            self.cells = vec![Vec::new(); width.checked_mul(height)?];
            self.width = width;
            self.height = height;
        }
        let mut cursor_row = 0;
        let mut cursor_end = 0;
        for row in 0..height {
            let mut col = 0;
            while col < width {
                if self.cells[row * width + col] == cell(row, col) {
                    col += 1;
                    continue;
                }
                if self.output.is_empty() {
                    self.output.extend_from_slice(prefix);
                }
                if row > cursor_row {
                    write!(self.output, "\x1b[{}B", row - cursor_row).unwrap();
                }
                write!(self.output, "\x1b[{}G", col + 1).unwrap();
                loop {
                    let bytes = cell(row, col);
                    let previous = &mut self.cells[row * width + col];
                    if previous == bytes {
                        break;
                    }
                    if !single_column(bytes) {
                        self.unsupported = true;
                        return None;
                    }
                    self.output.extend_from_slice(bytes);
                    previous.clear();
                    previous.extend_from_slice(bytes);
                    col += 1;
                    if col == width {
                        break;
                    }
                }
                cursor_row = row;
                cursor_end = col;
            }
        }
        if !self.output.is_empty() && (cursor_row + 1 != height || cursor_end != width) {
            if cursor_row + 1 < height {
                write!(self.output, "\x1b[{}B", height - 1 - cursor_row).unwrap();
            }
            write!(self.output, "\x1b[{}G", width).unwrap();
            // Reproduce the full frame's cursor position, including pending wrap.
            self.output.extend_from_slice(cell(height - 1, width - 1));
        }
        Some(&self.output)
    }
}

fn single_column(bytes: &[u8]) -> bool {
    let Ok(text) = std::str::from_utf8(bytes) else {
        return false;
    };
    if !text.contains('\x1b') {
        return one_column(text);
    }
    let mut symbol = String::new();
    let mut chars = text.chars();
    while let Some(ch) = chars.next() {
        if ch == '\x1b' {
            if chars.next() != Some('[') {
                return false;
            }
            loop {
                match chars.next() {
                    Some('m') => break,
                    Some(ch) if ch.is_ascii_digit() || ch == ';' || ch == ':' => {}
                    _ => return false,
                }
            }
        } else {
            symbol.push(ch);
        }
    }
    one_column(&symbol)
}

/// unicode-width counts a lone control character as one column, but a
/// terminal moves the cursor for it instead of drawing a cell.
fn one_column(symbol: &str) -> bool {
    !symbol.chars().any(char::is_control) && UnicodeWidthStr::width(symbol) == 1
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn unchanged_frames_write_nothing_and_removed_cells_are_erased() {
        let mut out = DifferentialOutput::default();
        assert!(!out.frame(3, 2, b"TOP", |_, _| b" ").unwrap().is_empty());
        assert_eq!(out.frame(3, 2, b"TOP", |_, _| b" ").unwrap(), b"");
        assert_eq!(
            out.frame(3, 2, b"TOP", |row, col| {
                if row == 0 && col == 1 {
                    b"X"
                } else {
                    b" "
                }
            })
            .unwrap(),
            b"TOP\x1b[2GX\x1b[1B\x1b[3G "
        );
        assert_eq!(
            out.frame(3, 2, b"TOP", |_, _| b" ").unwrap(),
            b"TOP\x1b[2G \x1b[1B\x1b[3G "
        );
    }

    #[test]
    fn resize_repaints_and_last_column_keeps_pending_wrap() {
        let mut out = DifferentialOutput::default();
        assert_eq!(
            out.frame(1, 1, b"TOP", |_, _| b"X").unwrap(),
            b"TOP\x1b[1GX"
        );
        assert_eq!(
            out.frame(2, 1, b"TOP", |_, _| b"X").unwrap(),
            b"TOP\x1b[1GXX"
        );
        assert_eq!(out.frame(0, 0, b"TOP", |_, _| unreachable!()).unwrap(), b"");
    }

    #[test]
    fn styles_and_unicode_are_preserved_and_wide_cells_fall_back() {
        assert!(single_column(b"\x1b[38;2;1;2;3mX\x1b[0m"));
        assert!(single_column("█".as_bytes()));
        assert!(single_column("e\u{301}".as_bytes()));
        assert!(!single_column("界".as_bytes()));
        assert!(!single_column(b"\x1b[2JX"));
        assert!(!single_column(b"\x08"));
        assert!(!single_column(b"\t"));
        assert!(!single_column(b"\x1b[31m\x08\x1b[0m"));
        let mut out = DifferentialOutput::default();
        assert!(out.frame(1, 1, b"TOP", |_, _| "界".as_bytes()).is_none());
        assert!(out.frame(1, 1, b"TOP", |_, _| b"X").is_none());
    }
}
