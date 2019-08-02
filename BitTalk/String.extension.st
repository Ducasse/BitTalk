Extension { #name : #String }

{ #category : #'*BitTalk' }
String >> bencoded [
	| stream |
	stream := WriteStream with: self size asString asByteArray.
	^ stream
		nextPutAll: ':' asByteArray;
		nextPutAll: self asByteArray;
		contents
]
