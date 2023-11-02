Extension { #name : #FamixTType }

{ #category : #'*AnalysisMooseEGF' }
FamixTType >> mooseNameOn: aStream [

	self typeContainer
		ifNotNil: [ :parent |
			|separator|
			separator := '::'.
			self isInnerClass ifTrue: [ separator := '$' ].
			parent mooseNameOn: aStream.
			aStream nextPutAll: separator  ].
	self name ifNotNil: [ :n | aStream nextPutAll: n ]
]
