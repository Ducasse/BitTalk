Extension { #name : #OrderedCollection }

{ #category : #'*BitTalk' }
OrderedCollection >> asFileReference [
	| fileRef |
	fileRef := FileSystem root.
	self isNotEmpty
		ifTrue: [ fileRef := self inject: fileRef into: [ :x :y | x / y ] ].
	^ fileRef
]

{ #category : #'*BitTalk' }
OrderedCollection >> bencoded [
	| stream |
	stream := WriteStream with: ByteArray new.
	stream nextPutAll: 'l' asByteArray.
	self do: [ :y | stream nextPutAll: y bencoded ].
	stream nextPutAll: 'e' asByteArray.
	^ stream contents 
]
