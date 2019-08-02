"
A BtPieceCounter is xxxxxxxxx.

Instance Variables
	count:		<Object>
	index:		<Object>

count
	- xxxxx

index
	- xxxxx

"
Class {
	#name : #BtPieceCounter,
	#superclass : #Object,
	#instVars : [
		'count',
		'index'
	],
	#category : #BitTalk
}

{ #category : #'instance creation' }
BtPieceCounter class >> index: pieceIndex count: count [
	^ BtPieceCounter new
		index: pieceIndex;
		count: count;
		yourself
]

{ #category : #comparing }
BtPieceCounter >> = anotherPieceCounter [
	^ self == anotherPieceCounter
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherPieceCounter species
				ifTrue: [ index = anotherPieceCounter index ]
				ifFalse: [ false ] ]
]

{ #category : #accessing }
BtPieceCounter >> count [
	^ count
]

{ #category : #accessing }
BtPieceCounter >> count: anObject [
	count := anObject
]

{ #category : #comparing }
BtPieceCounter >> hash [
	^ index hash
]

{ #category : #accessing }
BtPieceCounter >> index [
	^ index
]

{ #category : #accessing }
BtPieceCounter >> index: anObject [
	index := anObject
]

{ #category : #'initialize-release' }
BtPieceCounter >> initialize [
	super initialize.
	count := 0.
	index := nil
]

{ #category : #comparing }
BtPieceCounter >> lowerOrEqualThan: anotherPieceCounter [
	^ index <= anotherPieceCounter index

]

{ #category : #accessing }
BtPieceCounter >> modifyCountBy: amount [
	"Positive amount to increment. Negative amount to decrement. Return new count"

	| newCount |
	newCount := count + amount.
	^ count := newCount < 0
		ifTrue: [ 0 ]
		ifFalse: [ newCount ]
]

{ #category : #printing }
BtPieceCounter >> printOn: aStream [
	aStream
		nextPutAll: index asString;
		nextPutAll: '->';
		nextPutAll: count asString
]

{ #category : #comparing }
BtPieceCounter >> rarestOrEqualThan: anotherPieceCounter [
	^ count <= anotherPieceCounter count
]
