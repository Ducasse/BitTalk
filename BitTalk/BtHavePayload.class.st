"
A BtHavePayload is xxxxxxxxx.

"
Class {
	#name : #BtHavePayload,
	#superclass : #BtMessagePayload,
	#instVars : [
		'index'
	],
	#category : #'BitTalk-P2P'
}

{ #category : #comparing }
BtHavePayload >> = anotherPayload [
	^ self == anotherPayload
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherPayload species
				ifTrue: [ index = anotherPayload index ]
				ifFalse: [ false ] ]
]

{ #category : #'converting-arrays' }
BtHavePayload >> asByteArray [
	^ index asByteArrayOfSize: 4
]

{ #category : #accessing }
BtHavePayload >> index [
	^ index
]

{ #category : #accessing }
BtHavePayload >> index: anObject [
	index := anObject
]

{ #category : #'initialize-release' }
BtHavePayload >> initialize [
	super initialize.
	index := 0.
]

{ #category : #printing }
BtHavePayload >> printOn: aStream [
	aStream nextPutAll: index asString
]
