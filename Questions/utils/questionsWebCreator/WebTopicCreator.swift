//
//  CreatorWebSwiftWrapper.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 20/05/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import Foundation

struct WebTopicCreator {
	
	let numberOfSets: UInt8
	let questionsPerSet: UInt8
	let answersPerQuestion: UInt8
	
	init(numberOfSets: UInt8, questionsPerSet: UInt8, answersPerQuestion: UInt8) {
		self.numberOfSets = numberOfSets
		self.questionsPerSet = questionsPerSet
		self.answersPerQuestion = answersPerQuestion
	}

	var outputWebCode: String {
		
		// Bootstrap 4.1.0
		let bootstrapCSS = "<style>\(Bundle.main.fileContent(ofResource: "bootstrap.min", withExtension: "css") ?? "")</style>"
		let bootstrapScripts = "<script>\(Bundle.main.fileContent(ofResource: "bootstrap.min", withExtension: "js") ?? "")</script>"
		
		let extraStyles = """
       	<style>
			.body-style {
				margin: 10pt 10pt;
				background-color: \(UserDefaultsManager.darkThemeSwitchIsOn ? "black" : "white");
				color: \(UserDefaultsManager.darkThemeSwitchIsOn ? "white" : "black");
		        font-family: system-ui;
			}
			.rounded-button {
				width: 24pt;
			    height: 24pt;
				border-radius: 12pt;
				text-align: center;
				vertical-align: middle;
				line-height: 0;
                font-size: 1.2rem;
			   	padding: 0pt;
			
				color: white;
				background-color: \(UserDefaultsManager.darkThemeSwitchIsOn ? "orange" : "rgb(0, 122, 255)");
				border-color: \(UserDefaultsManager.darkThemeSwitchIsOn ? "orange" : "rgb(0, 122, 255)");
			}
		</style>
"""
		let scripts = "<script>\(Bundle.main.fileContent(ofResource: "WebTopicCreator-scripts", withExtension: "js") ?? "")</script>"
		
		/// Should not be enabled on normal fields since when scrolling it triggers it
		let focusInputFaster: (String) -> String = { inputID in
			return """
			<script>focusInputFaster("\(inputID)")</script>
			"""
		}
		let checkCheckboxFaster: (String) -> String = { checkboxID in
			return """
			<script>checkCheckboxFaster("\(checkboxID)")</script>
			"""
		}

		let options = """
		<section id="full-options" style="margin-top: 10pt">
		<h4>\(Localized.TopicsCreation_WebView_Options) <button id="options-button" type="button" class="btn btn-sm rounded-button"> + </button></h4>
		<section id="options-content" style="display: none">
			<div class="input-group mb-3" style="margin-top: 10pt;">
				<div class="input-group-prepend">
					<span class="input-group-text">\(Localized.TopicsCreation_WebView_Options_Name)</span>
				</div>
				<input id="topic-name" type="text" class="form-control" placeholder="(\(Localized.TopicsCreation_WebView_Options_NamePlaceholder))">
		        \(focusInputFaster("topic-name"))
			</div>
			<div class="input-group mb-3">
				<div class="input-group-prepend">
					<span class="input-group-text">\(Localized.TopicsCreation_WebView_Options_Time) (s)</span>
				</div>
				<input id="topic-time" type="number" pattern="[0-9]*" class="form-control" placeholder="(\(Localized.TopicsCreation_WebView_Options_TimePlaceholder))">
		        \(focusInputFaster("topic-time"))
			</div>
			<div class="input-group mb-3">
				<div class="input-group-prepend">
					<span class="input-group-text">\(Localized.TopicsCreation_WebView_Options_RandomOrderQuestions)</span>
					<span class="input-group-text">
						<input id="topic-random-order" type="checkbox" checked>
						\(checkCheckboxFaster("topic-random-order"))
					</span>
				</div>
			</div>
			<div class="input-group mb-3">
				<div class="input-group-prepend">
					<span class="input-group-text">\(Localized.TopicsCreation_WebView_Options_EnableHelp)</span>
					<span class="input-group-text">
						<input id="topic-help-button" type="checkbox" checked>
						\(checkCheckboxFaster("topic-help-button"))
					</span>
				</div>
			</div>
			<div class="input-group mb-3">
				<div class="input-group-prepend">
					<span class="input-group-text">\(Localized.TopicsCreation_WebView_Options_ShowCorrectIncorrect)</span>
					<span class="input-group-text">
						<input id="topic-correct-answer" type="checkbox" checked>
		                \(checkCheckboxFaster("topic-correct-answer"))
					</span>
				</div>
			</div>
			<div class="input-group mb-3">
				<div class="input-group-prepend">
					<span class="input-group-text">\(Localized.TopicsCreation_WebView_Options_ForceChooseCorrectAnswers)</span>
					<span class="input-group-text">
						<input id="topic-force-choose" type="checkbox">
		                \(checkCheckboxFaster("topic-force-choose"))
					</span>
				</div>
			</div>
		</section>
	</section>
	<script>hideSectionWithButton("options-content", "options-button")</script>
"""
		
		var sets = ""
		for i in 1...self.numberOfSets {
			sets += """
			<section id="full-set-\(i)" style="margin-top: 10pt">
			<h4><button id="set-\(i)-button" type="button" class="btn btn-sm rounded-button" style="margin-right: 6pt"> + </button>\(Localized.TopicsCreation_WebView_Set) \(i) </h4>
			    <section id="set-\(i)-content" style="display: none">
			"""
			
			var questions = ""
			for j in 1...self.questionsPerSet {
				questions += """
				<section id="full-question-\(i)-\(j)" style="margin-top: 10pt; margin-left: 6pt">
				    <h4><button id="question-\(i)-\(j)-button" type="button" class="btn btn-sm rounded-button" style="margin-right: 6pt"> + </button>\(Localized.TopicsCreation_WebView_Question) \(j)</h4>
					<section id="question-\(i)-\(j)-content" style="display: none; margin-top: 10pt">
						<div class="input-group mb-3">
							<div class="input-group-prepend">
								<span class="input-group-text">\(Localized.TopicsCreation_WebView_Question)</span>
							</div>
							<textarea id="question-text-\(i)-\(j)" class="form-control"></textarea>
						</div>
						<div class="input-group mb-3">
							<div class="input-group-prepend">
								<span class="input-group-text">\(Localized.TopicsCreation_WebView_ImageURL)</span>
							</div>
							<input id="question-image-\(i)-\(j)" type="url" class="form-control" placeholder="(\(Localized.TopicsCreation_WebView_ImageURLPlaceholder))">
						</div>
				        <section id="answers" style="padding-top: 10pt">
				"""
				
				var answers = ""
				for k in 1...self.answersPerQuestion {
					answers += """
					<div class="input-group mb-3">
						<div class="input-group-prepend">
							<span class="input-group-text">\(Localized.TopicsCreation_WebView_Answer) \(k)</span>
							<span class="input-group-text"><input id="answer-correct-\(i)-\(j)-\(k)" type="checkbox"></span>
					        \(checkCheckboxFaster("answer-correct-\(i)-\(j)-\(k)"))
						</div>
						<input id="answer-\(i)-\(j)-\(k)" type="text" class="form-control" required>
					</div>
					"""
				}
				
				questions += """
						\(answers)
				        </section>
					</section>
				</section>
				<script>hideSectionWithButton("question-\(i)-\(j)-content", "question-\(i)-\(j)-button")</script>
				"""
			}
	
			sets += """
			    \(questions)
			</section>
			</section>
			<script>hideSectionWithButton("set-\(i)-content", "set-\(i)-button")</script>
			"""
		}
		
		return """
		<!DOCTYPE html>
		<html>
			<head>
				<meta charset="UTF-8">
		        <meta name="viewport" content="width=device-width, user-scalable=no">
				<title>Creator Web</title>
				\(bootstrapCSS)
				\(bootstrapScripts)
		        \(scripts)
			</head>
			\(extraStyles)
			<body class="body-style">
				<h1 style="font-weight: bold">\(Localized.TopicsCreation_WebView_Title)</h1>
				\(options)
				\(sets)
			</body>
		</html>

"""
	}
}
