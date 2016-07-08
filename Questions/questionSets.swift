import Foundation

func getSet(set: Int, nQuestions: Int) -> [Question] {

	var questions: [Question] = []
	let nAnswers = 4

	for i in 1...nQuestions {
		questions += [Question(question: "S\(set)Q\(i)".localized(VC.language!), answers: [], answer: nil)]

		for j in 1...nAnswers {
			questions[i - 1].answers += ["S\(set)Q\(i)A\(j)".localized(VC.language!)]
		}
	}

	return questions
}

// QUESTIONS SET #1
func getSet1() -> [Question] {

	var questions: [Question] = getSet(1, nQuestions: 4)

	questions[0].answer = 3
	questions[1].answer = 0
	questions[2].answer = 1
	questions[3].answer = 1

	return questions
}

// SET #2
func getSet2() -> [Question] {

	var questions: [Question] = getSet(2, nQuestions: 3)

	questions[0].answer = 0
	questions[1].answer = 1
	questions[2].answer = 2

	return questions
}

// SET #3
func getSet3() -> [Question] {

	var questions: [Question] = getSet(3, nQuestions: 5)

	questions[0].answer = 0
	questions[1].answer = 2
	questions[2].answer = 3
	questions[3].answer = 3
	questions[4].answer = 3

	return questions
}

// GET SET *
func getSets(set: Int) -> [Question] {
	
	switch set {
	case 1:
		return getSet1()
	case 2:
		return getSet2()
	case 3:
		return getSet3()
	default:
		return getSet1()
	}
}
