Extension { #name : #Integer }

{ #category : #'*BitTalk' }
Integer >> asIPv4 [
	^self asByteArrayOfSize: 4.
]

{ #category : #'*BitTalk' }
Integer >> asIPv6 [
	^self asByteArrayOfSize: 16.
]

{ #category : #'*BitTalk' }
Integer >> asPortNumber [
	^self asByteArrayOfSize: 2.
]

{ #category : #'*BitTalk' }
Integer >> bencoded [
	^ZnUTF8Encoder new encodeString: 'i' ,  self asString , 'e'
]
