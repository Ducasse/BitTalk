"
*** NO COMMENTS... YET***
"
Class {
	#name : #BaselineOfBitTalk,
	#superclass : #BaselineOf,
	#category : #'BitTalk-Baseline'
}

{ #category : #'as yet unclassified' }
BaselineOfBitTalk >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec package: 'BitTalk'.
			spec group: 'default' with: #('BitTalk') ]

]
