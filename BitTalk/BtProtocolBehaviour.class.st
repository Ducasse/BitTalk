"
A BtProtocolBehaviour is xxxxxxxxx.

"
Class {
	#name : #BtProtocolBehaviour,
	#superclass : #Object,
	#instVars : [
		'bytes'
	],
	#category : #'BitTalk-P2P'
}

{ #category : #'instance creation' }
BtProtocolBehaviour class >> from: aByteArray [
	^self new bytes: aByteArray ; yourself 
]

{ #category : #comparing }
BtProtocolBehaviour >> = anotherProtocolBehaviour [
	^ self == anotherProtocolBehaviour
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherProtocolBehaviour species
				ifTrue: [ bytes = anotherProtocolBehaviour bytes ]
				ifFalse: [ false ]
		]
]

{ #category : #'converting-arrays' }
BtProtocolBehaviour >> asByteArray [
	^ bytes
]

{ #category : #accessing }
BtProtocolBehaviour >> bytes [
	^ bytes
]

{ #category : #accessing }
BtProtocolBehaviour >> bytes: aByteArray [
	aByteArray class ~= ByteArray ifTrue:[self error:'Bad class'].
	aByteArray size ~= 8 ifTrue:[self error: 'Bad size'].
	bytes := aByteArray
]

{ #category : #operations }
BtProtocolBehaviour >> disableDHT [
	bytes at: 8 put: ((bytes at: 8) bitAnd: 254)
]

{ #category : #operations }
BtProtocolBehaviour >> enableDHT [
	bytes at: 8 put: ((bytes at: 8) bitOr: 1)
]

{ #category : #'initialize-release' }
BtProtocolBehaviour >> initialize [
	super initialize.
	bytes := ByteArray new: 8
]

{ #category : #testing }
BtProtocolBehaviour >> isDHTEnabled [
	| byte |
	byte := bytes at: 8.
	^ (byte bitAt: byte lowBit) = 1
]
