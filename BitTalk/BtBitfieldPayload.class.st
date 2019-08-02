"
A BtBitfieldPayload is xxxxxxxxx.

"
Class {
	#name : #BtBitfieldPayload,
	#superclass : #BtMessagePayload,
	#instVars : [
		'bitfield'
	],
	#category : #'BitTalk-P2P'
}

{ #category : #comparing }
BtBitfieldPayload >> = anotherPayload [
	^ self == anotherPayload 
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherPayload species
				ifTrue: [ bitfield = anotherPayload bitfield ]
				ifFalse: [ false ] 
		]
]

{ #category : #'converting-arrays' }
BtBitfieldPayload >> asByteArray [
	^bitfield field
]

{ #category : #accessing }
BtBitfieldPayload >> bitfield [
	^ bitfield
]

{ #category : #accessing }
BtBitfieldPayload >> bitfield: anObject [
	bitfield := anObject
]

{ #category : #'initialize-release' }
BtBitfieldPayload >> initialize [
	super initialize.
	bitfield:= BtBitfield new.
]

{ #category : #printing }
BtBitfieldPayload >> printOn: aStream [
	aStream nextPutAll: bitfield asString
]
