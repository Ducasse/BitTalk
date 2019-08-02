"
*** NO COMMENTS... YET***
"
Class {
	#name : #BaselineOfBitTalk,
	#superclass : #BaselineOf,
	#category : #BaselineOfBitTalk
}

{ #category : #baseline }
BaselineOfBitTalk >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec package: 'BitTalk'.
			spec group: 'default' with: #('BitTalk') ]

]
