import Foundation

struct Quiz {
	
	private(set) var name = String()
	private(set) var content: [[[String: Any]]]!
	
	init(name: String) {
		self.name = name
		
		let path = Bundle.main.path(forResource: name, ofType: "json")
		let url = URL(fileURLWithPath: path!)
		
		if let data = try? Data(contentsOf: url) {
			content = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [[[String: Any]]]
		}
	}
	
	static let quizzes = [Quiz(name: "Technology"), Quiz(name: "Social"), Quiz(name: "People")]
}
