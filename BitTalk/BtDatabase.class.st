"
A BtDatabase is xxxxxxxxx.

Instance Variables
	location:		<Object>

location
	- xxxxx

"
Class {
	#name : #BtDatabase,
	#superclass : #Object,
	#instVars : [
		'location'
	],
	#classVars : [
		'Sharing',
		'StorageName'
	],
	#category : #BitTalk
}

{ #category : #'initialize-release' }
BtDatabase class >> initialize [
	super initialize.	
	Sharing:='sharing'.
	StorageName:='storageName'.
]

{ #category : #accessing }
BtDatabase >> delete [
	location ensureDeleteAll.
	location:= nil.
]

{ #category : #accessing }
BtDatabase >> deleteAttribute: attribute [
	(location / attribute) ensureDelete .
]

{ #category : #accessing }
BtDatabase >> location [
	^ location
]

{ #category : #accessing }
BtDatabase >> location: newLocation [	
	location isNil
		ifTrue:[ newLocation ensureCreateDirectory ]
		ifFalse: [ 
			location ~= newLocation 
				ifTrue:[location moveTo: newLocation].
		].	
	location := newLocation
	 
]

{ #category : #accessing }
BtDatabase >> metainfoFile [
	^location isNil 
		ifTrue:[nil] 
		ifFalse:[location children detect:[:x| x isTorrent] ifNone:[nil]] 
]

{ #category : #accessing }
BtDatabase >> metainfoFile: newMetainfoFile [
	location isNil 
		ifTrue:[self error: 'location not exists'] 
		ifFalse:[
			| oldMetainfoFile |
			oldMetainfoFile:=location children detect:[:x| x isTorrent] ifNone:[nil].
			oldMetainfoFile isNotNil 
				ifTrue:[oldMetainfoFile ensureDelete ].
			newMetainfoFile copyTo: (location / (newMetainfoFile basename))
		] 
]

{ #category : #accessing }
BtDatabase >> select: attribute [
	"Consulto el valor de attribute en mi base de datos y lo devuelvo. Devuelvo nil si no est√° definido."

	| file |
	location ifNil: [ self error: 'database cannot be nil' ].
	file := location children detect: [ :x | attribute = x basename ] ifNone: [ nil ].
	^ file ifNil: [ nil ] ifNotNil: [ file readStreamDo: [ :x | x contents ] ]
]

{ #category : #accessing }
BtDatabase >> update: attribute value: aString [
"Actualizo attribute en mi base de datos."
	|  file |
	file:=location children detect:[:x| attribute = x basename ] ifNone:[nil].
	file isNil
		ifTrue:[file:=(location / attribute) ensureCreateFile ].
	file writeStreamDo: [ :x | 
		x nextPutAll: aString.
		x truncate: x position.
	]
]
