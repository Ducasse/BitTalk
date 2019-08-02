Extension { #name : #ByteArray }

{ #category : #'*BitTalk' }
ByteArray >> bedecoded [
	^ self readStream bedecoded
]

{ #category : #'*BitTalk' }
ByteArray >> bencoded [
	| length |
	length:=self size asString asByteArray.
	^length , $: asInteger asByteArray  , self .
]

{ #category : #'*BitTalk' }
ByteArray >> decodeHandshake [
	^self readStream decodeHandshake
]

{ #category : #'*BitTalk' }
ByteArray >> decodeMessage [
	^self readStream decodeMessage
]

{ #category : #'*BitTalk' }
ByteArray >> decodeUDPResponse [
	^self readStream decodeUDPResponse
]

{ #category : #'*BitTalk' }
ByteArray >> dotted [
	^String streamContents: [:stream | self asStringOn: stream delimiter: '.' ]
]
