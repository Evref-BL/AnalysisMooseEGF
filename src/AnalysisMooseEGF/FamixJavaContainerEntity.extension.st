Extension { #name : #FamixJavaContainerEntity }

{ #category : #'*AnalysisMooseEGF' }
FamixJavaContainerEntity >> mooseNameWithDots [

	self resetMooseName.
	^ self mooseName ifNotNil: [ '.' join: (self mooseName substrings: '::') ].
]

{ #category : #'*AnalysisMooseEGF' }
FamixJavaContainerEntity >> mooseNameWithDotsJVMFormat [


	self resetMooseName.
	^ 	self mooseName ifNotNil: [ :mName |  '.' join: (mName substrings: '::') ]
]

{ #category : #'*AnalysisMooseEGF' }
FamixJavaContainerEntity >> mooseNameWithDotsNoParenthesis [

	| res |
	res := self mooseNameWithDots.
	res := res
		       copyFrom: 1
		       to: (res indexOfAnyOf: { $( } startingAt: 1) - 1.

	
	1 to: res size do: [ :i | 
		
		(res at: i) = '$' ifTrue: [ res at:i put: '.' ].  
		
		 ].
	
	"res replaceAllRegex: '\$' with: '.'."
	
	^ res
]

{ #category : #'*AnalysisMooseEGF' }
FamixJavaContainerEntity >> mooseNameWithDotsNoParenthesisNoPackageName [

	| methodName className|
	className := self parentType name.
	methodName := self signature  copyFrom: 1
		       to: (self signature indexOfAnyOf: { $( } startingAt: 1) - 1.
	^ className, '.' , methodName
]
