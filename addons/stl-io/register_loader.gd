static var bootstrapped := Bootstrap()
static func Bootstrap() -> bool:
	STLIOImporter.RegisterFormatLoader()
	return true
