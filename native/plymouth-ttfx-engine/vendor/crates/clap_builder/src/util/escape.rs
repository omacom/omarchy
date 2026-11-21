#[cfg(feature = "help")]
use std::borrow::Cow;

pub(crate) struct Escape<'s>(pub(crate) &'s str);

impl<'s> Escape<'s> {
    pub(crate) fn needs_escaping(&self) -> bool {
        self.0.is_empty() || self.0.contains(char::is_whitespace)
    }

    #[cfg(feature = "help")]
    pub(crate) fn to_cow(&self) -> Cow<'s, str> {
        if self.needs_escaping() {
            Cow::Owned(format!("{:?}", self.0))
        } else {
            Cow::Borrowed(self.0)
        }
    }
}

impl std::fmt::Display for Escape<'_> {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        if self.needs_escaping() {
            std::fmt::Debug::fmt(self.0, f)
        } else {
            self.0.fmt(f)
        }
    }
}
