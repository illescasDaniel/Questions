import Foundation

struct Quiz {
	
	private(set) var name = String()
	private(set) var content = [[[String: Any]]]()
	
	init(name: String) {
		
		self.name = name
		
		guard let path = Bundle.main.path(forResource: name, ofType: "json") else { print("Quiz incorrect path"); return }
		let url = URL(fileURLWithPath: path)
		
		do {
			let data = try Data(contentsOf: url)
			content = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [[[String: Any]]]
		} catch {
			print("Error initializing quiz content")
		}
	}

	static let quizzes = [Quiz(name: "Technology"), Quiz(name: "Social"), Quiz(name: "People")]
}
