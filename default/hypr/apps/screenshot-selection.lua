-- Remove the 1px border around the slurp region selection used by recordings, OCR, and QR capture.
hl.layer_rule({ match = { namespace = "selection" }, no_anim = true, animation = "none" })

-- Keep the Omasnap overlay immediate. It stays visible to screen shares: hiding it blacks out the whole
-- fullscreen overlay in output captures, which breaks Omasnap's scroll capture.
hl.layer_rule({ match = { namespace = "^omasnap$" }, no_anim = true, animation = "none" })
