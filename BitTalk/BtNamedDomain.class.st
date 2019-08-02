"
A BtNamedDomain is xxxxxxxxx.

"
Class {
	#name : #BtNamedDomain,
	#superclass : #BtDomain,
	#instVars : [
		'name'
	],
	#category : #BitTalk
}

{ #category : #comparing }
BtNamedDomain >> = anotherDomain [
	^ self == anotherDomain
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherDomain species
				ifTrue: [ address = anotherDomain address and: [ name = anotherDomain name ] ]
				ifFalse: [ false ] 
		]
]

{ #category : #comparing }
BtNamedDomain >> hash [
	^(address asByteArray , (name hash) asByteArray) asInteger
]

{ #category : #'initialize-release' }
BtNamedDomain >> initialize [
	super initialize.
	name := ByteString new.
]

{ #category : #accessing }
BtNamedDomain >> name [
	^name
]

{ #category : #accessing }
BtNamedDomain >> name: aString [
	name := aString.
	self resolveName.
]

{ #category : #operations }
BtNamedDomain >> resolveName [
	address:= [(NetNameResolver addressForName: name) asInteger ] on: NameLookupFailure do: [:ex | ex return: 0].

]
