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
