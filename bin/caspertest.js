require('firebase/firebase.js');
var casper = require("casper").create({
	verbose: true,
    logLevel: "debug",
	onRunComplete: function onRunComplete() {
		casper.steps=[];
		casper.step=0;
		}
});

casper.start("http://www.pdf995.com/samples/pdfeditsample.pdf", function() {
	this.download("http://www.pdf995.com/samples/pdfeditsample.pdf", "temp/tmattison/pdf.pdf");
}).run();