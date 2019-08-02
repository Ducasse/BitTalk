"
A BtByteRate is xxxxxxxxx.

Instance Variables
	amount:		<Object>
	mode:		<Object>
	timeUnit:		<Object>

amount
	- xxxxx

mode
	- xxxxx

timeUnit
	- xxxxx

"
Class {
	#name : #BtByteDisplay,
	#superclass : #Object,
	#instVars : [
		'amount'
	],
	#classVars : [
		'ByteSymbol',
		'Ei',
		'Gi',
		'Ki',
		'Mi',
		'Pi',
		'Ti',
		'Yi',
		'Zi'
	],
	#category : #BitTalk
}

{ #category : #'initialize-release' }
BtByteDisplay class >> initialize [
	super initialize.
	ByteSymbol := 'B'.
	Ki := 2 raisedTo: 10.
	Mi := 2 raisedTo: 20.
	Gi := 2 raisedTo: 30.
	Ti := 2 raisedTo: 40.
	Pi := 2 raisedTo: 50.
	Ei := 2 raisedTo: 60.
	Zi := 2 raisedTo: 70.
	Yi := 2 raisedTo: 80.
]

{ #category : #comparing }
BtByteDisplay >> >= anotherByteDisplay [
	^ self amount >= anotherByteDisplay amount
]

{ #category : #accessing }
BtByteDisplay >> amount [
	^ amount
]

{ #category : #accessing }
BtByteDisplay >> amount: anObject [
	amount := anObject
]

{ #category : #accessing }
BtByteDisplay >> increaseBy: anInteger [
	amount:= amount + anInteger
]

{ #category : #'initialize-release' }
BtByteDisplay >> initialize [
	super initialize.
	amount := 0.
	
]

{ #category : #printing }
BtByteDisplay >> printOn: aStream [
	| stringStream |
	stringStream := WriteStream with: String new.
	stringStream
		nextPutAll: self properAmount asString;
		nextPutAll: ' ';
		nextPutAll: self properPrefix;
		nextPutAll: ByteSymbol.
	aStream nextPutAll: stringStream contents
]

{ #category : #operations }
BtByteDisplay >> properAmount [
	^ self properAmountRound: 1
]

{ #category : #operations }
BtByteDisplay >> properAmountRound: anInteger [
	| properAmount |
	properAmount:= amount >= Yi
		ifTrue: [ amount / Yi asFloat ]
		ifFalse: [ 
			amount >= Zi
				ifTrue: [ amount / Zi asFloat ]
				ifFalse: [ 
					amount >= Ei
						ifTrue: [ amount / Ei asFloat ]
						ifFalse: [ 
							amount >= Pi
								ifTrue: [ amount / Pi asFloat ]
								ifFalse: [ 
									amount >= Ti
										ifTrue: [ amount / Ti asFloat ]
										ifFalse: [ 
											amount >= Gi
												ifTrue: [ amount / Gi asFloat ]
												ifFalse: [ 
													amount >= Mi
														ifTrue: [ amount / Mi asFloat ]
														ifFalse: [ 
															amount >= Ki
																ifTrue: [ amount / Ki asFloat ]
																ifFalse: [ amount ] ] ] ] ] ] ] ].
		^ properAmount round: anInteger							
]

{ #category : #operations }
BtByteDisplay >> properPrefix [
	^ amount >= Yi
		ifTrue: [ 'Yi' ]
		ifFalse: [ 
			amount >= Zi
				ifTrue: [ 'Zi' ]
				ifFalse: [ 
					amount >= Ei
						ifTrue: [ 'Ei' ]
						ifFalse: [ 
							amount >= Pi
								ifTrue: [ 'Pi' ]
								ifFalse: [ 
									amount >= Ti
										ifTrue: [ 'Ti' ]
										ifFalse: [ 
											amount >= Gi
												ifTrue: [ 'Gi' ]
												ifFalse: [ 
													amount >= Mi
														ifTrue: [ 'Mi' ]
														ifFalse: [ 
															amount >= Ki
																ifTrue: [ 'Ki' ]
																ifFalse: [ '' ] ] ] ] ] ] ] ]
]
