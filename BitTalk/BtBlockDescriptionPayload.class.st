"
A BtBlockDescriptionPayload is xxxxxxxxx.

"
Class {
	#name : #BtBlockDescriptionPayload,
	#superclass : #BtMessagePayload,
	#instVars : [
		'begin',
		'index',
		'length'
	],
	#category : #'BitTalk-P2P'
}

{ #category : #comparing }
BtBlockDescriptionPayload >> = anotherPayload [
	^ self == anotherPayload 
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherPayload species
				ifTrue: [ index = anotherPayload index and:[begin = anotherPayload begin and:[length = anotherPayload length ] ]]
				ifFalse: [ false ] 
		]
]

{ #category : #'converting-arrays' }
BtBlockDescriptionPayload >> asByteArray [
	| bytes |
	bytes := OrderedCollection new.
	bytes
		addAll: (index asByteArrayOfSize: 4);
		addAll: (begin asByteArrayOfSize: 4);
		addAll: (length asByteArrayOfSize: 4).
	^ bytes asByteArray
]

{ #category : #accessing }
BtBlockDescriptionPayload >> begin [
	^ begin
]

{ #category : #accessing }
BtBlockDescriptionPayload >> begin: anObject [
	begin := anObject
]

{ #category : #accessing }
BtBlockDescriptionPayload >> index [
	^ index
]

{ #category : #accessing }
BtBlockDescriptionPayload >> index: anObject [
	index := anObject
]

{ #category : #'initialize-release' }
BtBlockDescriptionPayload >> initialize [
	super initialize.
	begin := 0.
	index := 0.
	length := 1.
]

{ #category : #accessing }
BtBlockDescriptionPayload >> length [
	^ length
]

{ #category : #accessing }
BtBlockDescriptionPayload >> length: anObject [
	length := anObject
]

{ #category : #printing }
BtBlockDescriptionPayload >> printOn: aStream [
	aStream
		nextPutAll: index asString;
		nextPutAll: ' ';
		nextPutAll: begin asString;
		nextPutAll: ' ';
		nextPutAll: length asString
]
