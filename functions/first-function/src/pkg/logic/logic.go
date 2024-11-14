package logic

type LogicInterface interface {
	Do()
}

type Logic struct{}

func New() LogicInterface {
	return &Logic{}
}
