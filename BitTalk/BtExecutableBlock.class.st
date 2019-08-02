"
A BtResettableProcess is xxxxxxxxx.

"
Class {
	#name : #BtExecutableBlock,
	#superclass : #Object,
	#instVars : [
		'block',
		'process',
		'name',
		'priority'
	],
	#category : #BitTalk
}

{ #category : #accessing }
BtExecutableBlock >> block [
	^ block
]

{ #category : #accessing }
BtExecutableBlock >> block: aBlock [
	block := aBlock.
]

{ #category : #'initialize-release' }
BtExecutableBlock >> initialize [
	super initialize.
	name := ''.
	block := [].
	priority := Processor userBackgroundPriority .
]

{ #category : #'initialize-release' }
BtExecutableBlock >> initializeProcess [
	process ifNotNil: [ self terminate ].
	process := block newProcess .
	process name: name.
	process priority: priority 
]

{ #category : #testing }
BtExecutableBlock >> isScheduled [
	^ process isSuspended not and:[process isTerminated not]
]

{ #category : #testing }
BtExecutableBlock >> isSuspended [
	^ process isSuspended
]

{ #category : #testing }
BtExecutableBlock >> isTerminated [
	^process isNil 
]

{ #category : #accessing }
BtExecutableBlock >> name [
	^name 
]

{ #category : #accessing }
BtExecutableBlock >> name: aString [
	name:= aString.
	process ifNotNil: [ process name: name ].
]

{ #category : #accessing }
BtExecutableBlock >> priority [
	^ priority
]

{ #category : #accessing }
BtExecutableBlock >> priority: anInteger [
	(anInteger between: Processor lowestPriority and: Processor highestPriority)
		ifTrue: [ 
			process ifNotNil: [ process priority: anInteger ].
			priority := anInteger ]
		ifFalse: [ self error: 'Invalid priority: ' , anInteger printString ]
]

{ #category : #accessing }
BtExecutableBlock >> process [
	^ process
]

{ #category : #operations }
BtExecutableBlock >> resume [
	process ifNil: [ self initializeProcess ].
	self isScheduled
		ifTrue: [ ^ self ].
	process isTerminated
		ifTrue: [ self initializeProcess ].
	process resume
]

{ #category : #operations }
BtExecutableBlock >> terminate [
	process
		ifNotNil: [ 
			process terminate.
			process := nil.
			Smalltalk garbageCollect ]
]
