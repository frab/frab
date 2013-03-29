# disable xml parameter parsing
ActionDispatch::ParamsParser::DEFAULT_PARSERS.delete(Mime::XML)
