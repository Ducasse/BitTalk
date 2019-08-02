"
Represento la información bedecodificada de un fichero metainfo (.torrent).
"
Class {
	#name : #BtMetainfo,
	#superclass : #Dictionary,
	#classVars : [
		'DefaultPieceLength',
		'Sha1Length'
	],
	#category : #BitTalk
}

{ #category : #'instance creation' }
BtMetainfo class >> from: aDictionary [
	| metainfo |
	metainfo := self new.
	aDictionary associationsDo: [ :association | metainfo add: association ].
	^ metainfo
]

{ #category : #'initialize-release' }
BtMetainfo class >> initialize [
	super initialize.
	Sha1Length:=20.
	DefaultPieceLength:=2 raisedTo: 19
]

{ #category : #'instance creation' }
BtMetainfo class >> new [
	^ super new initialize
]

{ #category : #comparing }
BtMetainfo >> = anotherMetainfo [
	^ self == anotherMetainfo
		ifTrue: [ true ]
		ifFalse: [ 
			self species = anotherMetainfo species
				ifTrue: [ self hash = anotherMetainfo hash ]
				ifFalse: [ false ] ]
]

{ #category : #accessing }
BtMetainfo >> allSha1 [
	^self infoDictionary at:'pieces'
]

{ #category : #accessing }
BtMetainfo >> announce [
	^self at:'announce' 
]

{ #category : #metainfo }
BtMetainfo >> announceList [
	^self at:'announce-list' ifAbsent:[nil] 
]

{ #category : #metainfo }
BtMetainfo >> announceList: anOrderedCollection [
"anOrderedCollection must be an ordered collection of ordered collections of strings"
	^self at:'announce-list' put: anOrderedCollection 
]

{ #category : #metainfo }
BtMetainfo >> buildFileDictionaryOn: file at: storeLocation [
	| fileDict |
	fileDict:= Dictionary new.
	file readStreamDo: [ :x | 
		x binary. 
		fileDict at: 'length' put: x size.
		"fileDict at:'md5sum'put: (MD5 new hashStream: x) hex."
		fileDict at: 'path' put: (file asOrderedCollectionUpTo: storeLocation).									
	].
	^fileDict
]

{ #category : #metainfo }
BtMetainfo >> buildInfoDictionaryOn: path pieceLength: pieceLength [
	| dict sha1Values fileDictionaries |
	dict := Dictionary new.
	dict at: 'name' put: path basename.
	dict at: 'private' put: 0.
	dict at: 'piece length' put: pieceLength.
	path isFile
		ifTrue: [ 
			path
				readStreamDo: [ :x | 
					x binary.
					dict at: 'length' put: x size	"dict at:'md5sum'put: (MD5 new hashStream: x) hex." ].
			fileDictionaries := OrderedCollection with: (self buildFileDictionaryOn: path at: path) ]
		ifFalse: [ 
			fileDictionaries := path allFiles
				inject: OrderedCollection new
				into: [ :x :y | 
					x
						add: (self buildFileDictionaryOn: y at: path);
						yourself ].
			dict at: 'files' put: fileDictionaries ].
	sha1Values := (BtFileCollection fromFileDictionaries: fileDictionaries at: path) allSha1SplitEvery: pieceLength.
	dict at: 'pieces' put: sha1Values asString.
	self at: 'info' put: dict
]

{ #category : #metainfo }
BtMetainfo >> buildOn: path [
	self buildOn: path announce: 'http://tracker.com:80/announce' pieceLength: DefaultPieceLength
]

{ #category : #metainfo }
BtMetainfo >> buildOn: path announce: announce pieceLength: pieceLength [
	self
		keysAndValuesRemove: [ :x :y | true ];
		at: 'announce' put: announce;
		at: 'created by'
			put: Smalltalk version , '. Package: ' , self class package name asString , '. Class: ' , self class asString;
		at: 'creation date' put: DateAndTime now asUnixTime;
		at: 'encoding' put: 'ASCII';
		buildInfoDictionaryOn: path pieceLength: pieceLength
]

{ #category : #metainfo }
BtMetainfo >> buildOn: path pieceLength: pieceLength [
	self buildOn: path announce: 'http://tracker.com:80/announce' pieceLength: pieceLength
]

{ #category : #private }
BtMetainfo >> checkPieceIndex: pieceIndex [
	pieceIndex + 1 > self numPieces ifTrue:[self error:'bad piece index']
]

{ #category : #metainfo }
BtMetainfo >> comment [
	^self at:'comment' ifAbsent:[nil]
]

{ #category : #metainfo }
BtMetainfo >> comment: aString [
	^self at:'comment' put:aString
]

{ #category : #accessing }
BtMetainfo >> file: fileIndex [
	^self files at: fileIndex 
]

{ #category : #accessing }
BtMetainfo >> files [
	^self isSingleFileMode 
		ifTrue:[
			OrderedCollection with:
			(Dictionary new 
				at:'length' put: self length; 
				at:'path' put: OrderedCollection new;
				yourself )  
		]ifFalse:[self infoDictionary at:'files' ifAbsent:[nil]]

	
]

{ #category : #comparing }
BtMetainfo >> hash [
	"Hash is reimplemented because = is implemented."

	| infoDictionary |
	infoDictionary := self infoDictionary.
	^ infoDictionary ifNil: [ nil hash ] ifNotNil: [ (SHA1 hashStream: infoDictionary bencoded readStream) asInteger ]
]

{ #category : #metainfo }
BtMetainfo >> infoDictionary [
	^ self at:'info' ifAbsent:[nil]
]

{ #category : #accessing }
BtMetainfo >> isMultipleFileMode [
	^self isSingleFileMode not
]

{ #category : #accessing }
BtMetainfo >> isPrivate [
	^ (self infoDictionary at: 'private' ifAbsent: [ 0 ]) = 1
]

{ #category : #accessing }
BtMetainfo >> isPublic [
	^ self isPrivate not
]

{ #category : #accessing }
BtMetainfo >> isSingleFileMode [
	^ (self infoDictionary includesKey: 'files') not
]

{ #category : #accessing }
BtMetainfo >> lastPieceLength [
	| pieceLength remainder |
	pieceLength := self pieceLength.
	remainder := self length % pieceLength.
	^ remainder = 0
		ifTrue: [ pieceLength ]
		ifFalse: [ remainder ]
]

{ #category : #accessing }
BtMetainfo >> length [
	^ self isSingleFileMode
		ifTrue: [ self infoDictionary at: 'length' ]
		ifFalse: [ self files inject: 0 into: [ :x :y | x + (y at: 'length') ] ]
]

{ #category : #accessing }
BtMetainfo >> name [
	^self infoDictionary at:'name' ifAbsent:[nil]
]

{ #category : #accessing }
BtMetainfo >> numFiles [
	^self isSingleFileMode 
		ifTrue:[1]
		ifFalse:[(self infoDictionary at:'files') size]
]

{ #category : #accessing }
BtMetainfo >> numPieces [
	^(self allSha1 size) / Sha1Length
]

{ #category : #accessing }
BtMetainfo >> pieceLength [
	| infoDictionary |
	infoDictionary:=self infoDictionary. 
	infoDictionary isNil
		ifTrue:[self error: 'There is not a info dictionary'].
		
	^self infoDictionary at: 'piece length' ifAbsent:[nil]
]

{ #category : #accessing }
BtMetainfo >> pieceLength: anInteger [
	| infoDictionary |
	infoDictionary:= self infoDictionary .
	infoDictionary isNil
		ifTrue:[
			self at:'info' put: Dictionary new.
			(self at:'info') at:'piece length' put: anInteger. 
		]
		ifFalse:[infoDictionary at: 'piece length' put: anInteger]
]

{ #category : #accessing }
BtMetainfo >> pieceLengthOf: pieceIndex [
	self checkPieceIndex: pieceIndex.
	^pieceIndex + 1 = self numPieces
		ifTrue:[self lastPieceLength ]
		ifFalse:[self pieceLength ]  
]

{ #category : #accessing }
BtMetainfo >> setDefaultPieceLength [
	self pieceLength: DefaultPieceLength 
]

{ #category : #accessing }
BtMetainfo >> setPrivate [
	self infoDictionary at:'private' put: 1.
]

{ #category : #accessing }
BtMetainfo >> setPublic [
	self infoDictionary at:'private' put: 0.
]

{ #category : #accessing }
BtMetainfo >> sha1Of: pieceIndex [
	self checkPieceIndex: pieceIndex.
	^ self allSha1 copyFrom: pieceIndex * Sha1Length + 1 to: Sha1Length * (pieceIndex + 1)
]

{ #category : #metainfo }
BtMetainfo >> supportMultitracker [
	^self announceList ifNil: [ false ] ifNotNil: [ true ] 
]

{ #category : #metainfo }
BtMetainfo >> writeToFile: fileReference [
	(FileStream newFileNamed: fileReference pathString )
		binary;
		nextPutAll: self bencoded;
		close
]
