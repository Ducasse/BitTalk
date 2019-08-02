"
A BtDomain is xxxxxxxxx.

Instance Variables
	address:		<Object>
	name:		<Object>

address
	- xxxxx

name
	- xxxxx

"
Class {
	#name : #BtDomain,
	#superclass : #Object,
	#instVars : [
		'address'
	],
	#category : #BitTalk
}

{ #category : #comparing }
BtDomain >> = anotherDomain [
	^ self == anotherDomain
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherDomain species
				ifTrue: [ address = anotherDomain address ]
				ifFalse: [ false ]
		]
]

{ #category : #accessing }
BtDomain >> address [
	^ address
]

{ #category : #accessing }
BtDomain >> address: newAddress [
	address := newAddress.  
]

{ #category : #comparing }
BtDomain >> hash [
	^ address
]

{ #category : #'initialize-release' }
BtDomain >> initialize [
	super initialize.
	address := 0.
]

{ #category : #printing }
BtDomain >> printOn: aStream [
	aStream nextPutAll: address asIPv4 dotted
]
