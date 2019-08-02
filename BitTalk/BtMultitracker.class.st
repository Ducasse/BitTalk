"
A Multitracker is xxxxxxxxx.

Instance Variables
	position:		<Object>
	tierPosition:		<Object>

position
	- xxxxx

tierPosition
	- xxxxx

"
Class {
	#name : #BtMultitracker,
	#superclass : #Object,
	#instVars : [
		'position',
		'tierPosition',
		'tierCollection'
	],
	#category : #BitTalk
}

{ #category : #accessing }
BtMultitracker >> current [
	^ (tierCollection at: position) at: tierPosition 
]

{ #category : #'initialize-release' }
BtMultitracker >> initialize [
	super initialize.
	tierCollection:= (OrderedCollection new add: (OrderedCollection new); yourself).
	position:= 1.
	tierPosition:= 1.
]

{ #category : #operations }
BtMultitracker >> moveCurrentToFirst [
	| currentTier |
	tierPosition > 1
		ifFalse: [ ^ self ].
	currentTier := tierCollection at: position.
	currentTier swap: tierPosition with: 1
]

{ #category : #accessing }
BtMultitracker >> position [
	^ position
]

{ #category : #accessing }
BtMultitracker >> position: anObject [
	position := anObject
]

{ #category : #operations }
BtMultitracker >> selectFirst [
	position:= 1 .
	tierPosition:= 1
]

{ #category : #operations }
BtMultitracker >> selectLast [
	position:= tierCollection size .
	tierPosition:= tierCollection last size
]

{ #category : #operations }
BtMultitracker >> selectNext [
	| currentTier |
	currentTier := tierCollection at: position.
	tierPosition := tierPosition < currentTier size
		ifTrue: [ tierPosition + 1 ]
		ifFalse: [ 
			position := position < tierCollection size
				ifTrue: [ position + 1 ]
				ifFalse: [ 1 ].
			1 ]
]

{ #category : #operations }
BtMultitracker >> shuffle [
	tierCollection do: [ :x | x shuffle ].
]

{ #category : #accessing }
BtMultitracker >> tierCollection [
	^ tierCollection
]

{ #category : #accessing }
BtMultitracker >> tierCollection: anObject [
	tierCollection := anObject
]

{ #category : #accessing }
BtMultitracker >> tierPosition [
	^ tierPosition
]

{ #category : #accessing }
BtMultitracker >> tierPosition: anObject [
	tierPosition := anObject
]
