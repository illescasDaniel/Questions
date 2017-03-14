import Foundation

struct Quiz {
	
	private(set) var name = String()
	private(set) var contents: [[[String: Any]]]!
	
	init(name: String) {
		self.name = name
		
		let path = Bundle.main.path(forResource: name, ofType: "json")
		let url = URL(fileURLWithPath: path!)
		
		if let data = try? Data(contentsOf: url) {
			contents = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [[[String: Any]]]
		}
	}
	
	static let quizzes = [Quiz(name: "Technology"), Quiz(name: "Social"), Quiz(name: "People")]
}
