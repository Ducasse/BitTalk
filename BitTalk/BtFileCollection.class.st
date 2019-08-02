"
A BtFileCollection is xxxxxxxxx.

Instance Variables
	files:		<Object>

files
	- xxxxx

"
Class {
	#name : #BtFileCollection,
	#superclass : #OrderedCollection,
	#category : #'BitTalk-DataAccess'
}

{ #category : #'instance creation' }
BtFileCollection class >> fromFileDictionaries: fileDictionaries at: top [
	^ BtFileCollection
		withAll:
			(fileDictionaries
				collect: [ :fileDictionary | 
					| file |
					file := BtFile new.
					file
						finalSize: (fileDictionary at: 'length');
						reference: ((fileDictionary at: 'path') inject: top into: [ :currentPath :segment | currentPath / segment ]);
						yourself ])
]

{ #category : #'instance creation' }
BtFileCollection class >> new [
	^ super new initialize
]

{ #category : #operations }
BtFileCollection >> allSha1SplitEvery: pieceLength [
	|  numPieces sha1Values |
	self checkAllComplete.
	sha1Values := WriteStream with: ByteArray new.
	numPieces := (self length / pieceLength) ceiling.
	0 to: numPieces - 1 do: [ :index | 
		|amount|
		amount := pieceLength min: self length - (index * pieceLength). 
		sha1Values nextPutAll: (self sha1Offset: index * pieceLength amount: amount) ].
	^ sha1Values contents 
]

{ #category : #accessing }
BtFileCollection >> at: anInteger put: aBtFile [
	aBtFile species ~= BtFile
		ifTrue: [ self error: 'Bad class' ].
	super at: anInteger put: aBtFile
]

{ #category : #'private - operations' }
BtFileCollection >> checkAllComplete [
	(self anySatisfy: [ :file | file currentSize ~= file finalSize ])
		ifTrue: [ self error: 'files must be complete' ]
]

{ #category : #'private - operations' }
BtFileCollection >> checkOffset: offset amount: amount [
	(offset < 0 or: [ offset >= self length ])
		ifTrue: [ self error: 'offset out of bounds' ].
	offset + amount > self length
		ifTrue: [ self error: 'offset + amount out of bounds' ]
]

{ #category : #'private - operations' }
BtFileCollection >> filesToReadFirst: fileIndex offset: offset amount: amount [
	| remaining filesToAccess |
	remaining := amount + offset.
	filesToAccess := OrderedCollection new.
	[ remaining > 0 ]
		whileTrue: [ 
			| file fileSize fileReference |
			file := self at: fileIndex.
			fileReference := file reference.
			(fileReference exists not
				or: [ 
					fileSize := fileReference size.
					fileSize < remaining and: [ fileSize ~= file finalSize ] ])
				ifTrue: [ ^ nil ].
			remaining := remaining - fileSize.
			filesToAccess add: file.
			fileIndex := fileIndex + 1 ].
	^ filesToAccess
]

{ #category : #'private - operations' }
BtFileCollection >> filesToWriteFirst: fileIndex offset: offset amount: amount [
	|  remaining filesToAccess |
	remaining:= amount + offset.
	filesToAccess:= OrderedCollection new.
	[remaining > 0]
		whileTrue:[
			|file|
			file:= self at: fileIndex.
			remaining := remaining - (file finalSize).
			filesToAccess add: file.
			fileIndex := fileIndex + 1.	
		].
	^filesToAccess 
]

{ #category : #'private - operations' }
BtFileCollection >> firstFileIndex: offset [
	| fileIndex sum |
	sum := 0.
	fileIndex := 1.
	[ sum <= offset ]
		whileTrue: [ 
			sum := sum + (self at: fileIndex) finalSize.
			fileIndex := fileIndex + 1 ].
	^ fileIndex - 1
]

{ #category : #'private - operations' }
BtFileCollection >> firstFileOffset: offset [
	| fileIndex sum firstOffset |
	fileIndex := 1.
	sum := 0.
	firstOffset := 0.
	[ sum <= offset ]
		whileTrue: [ 
			firstOffset := offset - sum.
			sum := sum + (self at: fileIndex) finalSize.
			fileIndex := fileIndex + 1 ].
	^ firstOffset
]

{ #category : #operations }
BtFileCollection >> length [
	^ self inject: 0 into: [ :sum :file | sum + file finalSize ]
]

{ #category : #printing }
BtFileCollection >> printOn: aStream [
	self do: [ :each | aStream nextPutAll: each asString ] separatedBy: [ aStream nextPutAll: String cr ]
]

{ #category : #operations }
BtFileCollection >> readOffset: offset amount: amount [
	|  fileIndex fileOffset filesToRead remaining block fileReference |
	self checkOffset: offset amount: amount.	
	fileIndex:= self firstFileIndex: offset.	
	fileOffset:= self firstFileOffset: offset.	
	filesToRead:= self filesToReadFirst: fileIndex offset: fileOffset amount: amount.
	filesToRead ifNil: [ ^nil ].
		
	remaining := amount.
	fileIndex := 1.
	block:= WriteStream with: ByteArray new.	
	[remaining > 0]
		whileTrue: [
			fileReference := (filesToRead at: fileIndex) reference .
			fileReference readStreamDo: [ :x | 
				x binary.
				x skip: fileOffset .
				[remaining > 0 and:[x atEnd not]]
					whileTrue:[
						|chunk|
						chunk:=x next: remaining.
						block nextPutAll: chunk.
						remaining := remaining - (chunk size).	
					].			
				x atEnd
					ifTrue:[
						fileIndex := fileIndex + 1.
						fileOffset := 0.
					] ifFalse:[fileOffset := x position ].
			]. 							
		].							
	^block contents
]

{ #category : #operations }
BtFileCollection >> sha1Offset: offset amount: amount [
	^SHA1 hashStream: (self readOffset: offset amount: amount) readStream
]

{ #category : #operations }
BtFileCollection >> writeOffset: offset data: aByteArray [
	| fileReference remaining fileIndex fileOffset filesToWrite dataToWrite file chunkSize |
	remaining := aByteArray size.
	self checkOffset: offset amount: remaining.
	fileIndex := self firstFileIndex: offset.
	fileOffset := self firstFileOffset: offset.
	filesToWrite := self filesToWriteFirst: fileIndex offset: fileOffset amount: remaining.
	filesToWrite ifNil: [ ^ nil ].
	fileIndex := 1.
	dataToWrite := aByteArray readStream.
	[ remaining > 0 ]
		whileTrue: [ 
			| chunk |
			file := filesToWrite at: fileIndex.
			chunkSize := file finalSize - fileOffset min: remaining.
			chunk := dataToWrite next: chunkSize.
			fileReference := file reference.
			fileReference
				writeStreamDo: [ :x | 
					x
						binary;
						skip: fileOffset;
						nextPutAll: chunk ].
			remaining := remaining - chunkSize.
			fileIndex := fileIndex + 1.
			fileOffset := 0 ]
]
