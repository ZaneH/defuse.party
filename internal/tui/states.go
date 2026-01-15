package tui

type AppState int

const (
	StateMainMenu AppState = iota
	StateSectionSelect
	StateMissionSelect
	StateFreePlayMenu
	StateFreePlayAdvanced
	StateLoading
	StateBombSelection
	StateBombView
	StateModuleActive
	StateGameOver
)
