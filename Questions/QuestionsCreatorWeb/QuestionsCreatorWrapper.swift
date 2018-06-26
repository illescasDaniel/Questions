//
//  CreatorWebSwiftWrapper.swift
//  Questions
//
//  Created by Daniel Illescas Romero on 20/05/2018.
//  Copyright © 2018 Daniel Illescas Romero. All rights reserved.
//

import Foundation

struct QuestionsCreatorWrapper {
	
	let numberOfSets: UInt8
	let questionsPerSet: UInt8
	let answersPerQuestion: UInt8
	
	init(numberOfSets: UInt8, questionsPerSet: UInt8, answersPerQuestion: UInt8) {
		self.numberOfSets = numberOfSets
		self.questionsPerSet = questionsPerSet
		self.answersPerQuestion = answersPerQuestion
	}

	var web: String {

		/* REMOVED:
		<script async src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
		<script async src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.0/umd/popper.min.js" integrity="sha384-cs/chFZiN24E4KMATLdqdvsezGxaGsi4hLGOzlXwp5UZB1LY//20VyM2taTB4QvJ" crossorigin="anonymous"></script>
		*/
		let bootstrapp = """
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.0/css/bootstrap.min.css" integrity="sha384-9gVQ4dYFwwWSjIDZnLEWnxCjeSWFphJiwGPXr1jddIhOegiu1FwO5qRGvFXOdJZ4" crossorigin="anonymous" media="none" onload="if(media!='all')media='all'"><noscript><link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.0/css/bootstrap.min.css"></noscript>

		<script async defer src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.0/js/bootstrap.min.js" integrity="sha384-uefMccjFJAIv6A+rW+L4AHf99KvxDjWSu1z9VI8SKNVmz4sk7buKt/6v9KI65qnm" crossorigin="anonymous"></script>
"""
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
		let scripts = """
		<script>
            function focusInputFaster(inputID) {
				const inputElement = document.getElementById(inputID)
				inputElement.ontouchend = function (e) {
                    inputElement.focus()
					e.preventDefault()
				}
			}
			function checkCheckboxFaster(checkboxID) {
				const checkboxElement = document.getElementById(checkboxID)
				checkboxElement.ontouchend = function (e) {
					checkboxElement.click()
                    		e.preventDefault()
				}
			}
			function hideSectionWithButton(sectionID, buttonID) {
				
				const optionsSection = document.getElementById(sectionID)
				const optionsButton = document.getElementById(buttonID)
				
				optionsButton.ontouchend = function () {
					if (optionsSection.style.display == "none" || optionsSection.style.display == "") {
						optionsSection.style.display = "block"
						optionsButton.textContent = "-"
					} else {
						optionsSection.style.display = "none"
						optionsButton.textContent = "+"						
					}
				}
			}
		</script>
"""
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
		<h4>\("Options".localized) <button id="options-button" type="button" class="btn btn-sm rounded-button"> + </button></h4>
		<section id="options-content" style="display: none">
			<div class="input-group mb-3" style="margin-top: 10pt;">
				<div class="input-group-prepend">
					<span class="input-group-text">\("Name".localized)</span>
				</div>
				<input id="topic-name" type="text" class="form-control" placeholder="(\("Optional but recommended".localized))">
		        \(focusInputFaster("topic-name"))
			</div>
			<div class="input-group mb-3">
				<div class="input-group-prepend">
					<span class="input-group-text">\("Time per set".localized) (s)</span>
				</div>
				<input id="topic-time" type="number" pattern="[0-9]*" class="form-control" placeholder="(\("Optional".localized))">
		        \(focusInputFaster("topic-time"))
			</div>
			<div class="input-group mb-3">
				<div class="input-group-prepend">
					<span class="input-group-text">\("Questions in random order".localized)</span>
					<span class="input-group-text">
						<input id="topic-random-order" type="checkbox" checked>
						\(checkCheckboxFaster("topic-random-order"))
					</span>
				</div>
			</div>
			<div class="input-group mb-3">
				<div class="input-group-prepend">
					<span class="input-group-text">\("Enable help button".localized)</span>
					<span class="input-group-text">
						<input id="topic-help-button" type="checkbox" checked>
						\(checkCheckboxFaster("topic-help-button"))
					</span>
				</div>
			</div>
			<div class="input-group mb-3">
				<div class="input-group-prepend">
					<span class="input-group-text">\("Show Correct/Incorrect answers".localized)</span>
					<span class="input-group-text">
						<input id="topic-correct-answer" type="checkbox" checked>
		                \(checkCheckboxFaster("topic-correct-answer"))
					</span>
				</div>
			</div>
			<div class="input-group mb-3">
				<div class="input-group-prepend">
					<span class="input-group-text">\("Force to choose all correct answers".localized)</span>
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
			<h4><button id="set-\(i)-button" type="button" class="btn btn-sm rounded-button" style="margin-right: 6pt"> + </button>\("Set".localized) \(i) </h4>
			    <section id="set-\(i)-content" style="display: none">
			"""
			
			var questions = ""
			for j in 1...self.questionsPerSet {
				questions += """
				<section id="full-question-\(i)-\(j)" style="margin-top: 10pt; margin-left: 6pt">
				    <h4><button id="question-\(i)-\(j)-button" type="button" class="btn btn-sm rounded-button" style="margin-right: 6pt"> + </button>\("Question".localized) \(j)</h4>
					<section id="question-\(i)-\(j)-content" style="display: none; margin-top: 10pt">
						<div class="input-group mb-3">
							<div class="input-group-prepend">
								<span class="input-group-text">\("Question".localized)</span>
							</div>
							<textarea id="question-text-\(i)-\(j)" class="form-control"></textarea>
						</div>
						<div class="input-group mb-3">
							<div class="input-group-prepend">
								<span class="input-group-text">\("Image URL".localized)</span>
							</div>
							<input id="question-image-\(i)-\(j)" type="url" class="form-control" placeholder="(\("Optional".localized))">
						</div>
				        <section id="answers" style="padding-top: 10pt">
				"""
				
				var answers = ""
				for k in 1...self.answersPerQuestion {
					answers += """
					<div class="input-group mb-3">
						<div class="input-group-prepend">
							<span class="input-group-text">\("Answer".localized) \(k)</span>
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
		        \(bootstrapp)
		        \(scripts)
			</head>
			\(extraStyles)
			<body class="body-style">
				<h1 style="font-weight: bold">\("Topic Creator".localized)</h1>
				\(options)
				\(sets)
			</body>
		</html>

"""
	}
}
