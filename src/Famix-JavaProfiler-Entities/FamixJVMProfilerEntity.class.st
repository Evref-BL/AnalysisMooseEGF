Class {
	#name : #FamixJVMProfilerEntity,
	#superclass : #MooseEntity,
	#category : #'Famix-JavaProfiler-Entities-Entities'
}

{ #category : #meta }
FamixJVMProfilerEntity class >> annotation [

	<FMClass: #Entity super: #MooseEntity>
	<package: #'Famix-JavaProfiler-Entities'>
	<generated>
	<abstract>
	^ self
]

{ #category : #testing }
FamixJVMProfilerEntity class >> isAbstract [

	<generated>
	^ self == FamixJVMProfilerEntity
]

{ #category : #meta }
FamixJVMProfilerEntity class >> metamodel [

	<generated>
	^ FamixJVMProfilerModel metamodel
]
