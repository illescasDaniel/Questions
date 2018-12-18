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
