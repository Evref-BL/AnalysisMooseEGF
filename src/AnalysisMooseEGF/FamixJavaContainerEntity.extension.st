Extension { #name : #FamixJavaContainerEntity }

{ #category : #'*AnalysisMooseEGF' }
FamixJavaContainerEntity >> mooseNameWithDotsNoParenthesis [

	| res |
	res := self mooseNameWithDots.
	res := res
		       copyFrom: 1
		       to: (res indexOfAnyOf: { $( } startingAt: 1) - 1.
	res replaceAllRegex: '\$' with: '.'.
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
