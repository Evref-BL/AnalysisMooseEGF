Extension { #name : #FamixTMethod }

{ #category : #'*Famix-JavaProfiler-Entities-accessing' }
FamixTMethod >> JVMProcesses [
	"Relation named: #JVMProcesses type: #FamixJVMProfilerProcess opposite: #origin"

	<generated>
	<derived>
	<FMProperty: #JVMProcesses type: #FamixJVMProfilerProcess opposite: #origin>
	<package: #'Famix-JavaProfiler-Entities'>
	^ self attributeAt: #JVMProcesses ifAbsentPut: [ FMMultivalueLink on: self opposite: #origin: ]
]

{ #category : #'*Famix-JavaProfiler-Entities-accessing' }
FamixTMethod >> JVMProcesses: anObject [

	<generated>
	self JVMProcesses value: anObject
]
