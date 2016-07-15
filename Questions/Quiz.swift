import Foundation

struct Quiz {
	
	var question: String
	var answers: [String] = []
	var answer: Int?

	static func getSet(set: Int) -> [Quiz] {

		let sets = [

			// SOCIAL SET (set 0)
			[Quiz(question: "What's your name?".l, answers: ["Virginia".l, "Daniel".l, "Pete".l, "Mr. Incognito".l], answer: 3),
				Quiz(question: "🐶 or 🐱?".l, answers: ["🐱".l, "🐶".l, "Daniel".l, "Other".l], answer: 1),
				Quiz(question: "Do you like Pizza?".l, answers: ["I love it!".l, "Yes".l, "No".l, "Maybe".l], answer: 1)],

			// TECHNOLOGY SET
			[Quiz(question: "Best desktop OS".l, answers: ["macOS".l, "Windows".l, "MS-DOS 😎".l, "Linux c:".l], answer: 0),
				Quiz(question: "Best IDE".l, answers: ["Visual Studio".l, "Xcode".l, "Netbeans".l, "Eclipse".l], answer: 1),
				Quiz(question: "Best smartphone OS".l, answers: ["iOS".l, "Android".l, "BlackBerry OS".l, "Windows c:".l], answer: 0),
				Quiz(question: "Latest macOS version".l, answers: ["10.11.5".l, "10.2", "11".l, "10.12".l], answer: 3),
				Quiz(question: "Which Windows version is the best?".l, answers: ["Windows XP".l, "Windows 7".l, "Windows Vista".l, "Windows 10".l], answer: 3),
				Quiz(question: "iPhone, iPad or Mac?".l, answers: ["iPhone".l, "iPad".l, "mac".l, "Everyone c:".l], answer: 3)],

			// PEOPLE SET
			[Quiz(question: "How old is Barack Obama?".l, answers: ["> 50".l, "< 50".l, "35 ☺️".l, "> 60 👴🏿".l], answer: 0),
				Quiz(question: "Google CEO".l, answers: ["Larry Page".l, "Sergey Brin".l, "Sundar Pichai".l, "Andy Rubin".l], answer: 2)]

		]

		return (set >= 0 && set <= sets.count) ? sets[set]: [Quiz]()
	}

}
