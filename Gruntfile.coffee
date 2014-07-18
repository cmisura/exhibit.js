###
	Grunt build system
###
module.exports = (grunt) ->

	config =
		pkg: grunt.file.readJSON 'package.json'
		watch:
			stylus:
				files: ['css/*.styl']
				tasks: ['stylus','cssmin']
				#tasks: ['stylus','cssmin','sftp-deploy']

			coffee:
				files: ['js/*.coffee', 'js/vendor/*.coffee']
				tasks: [ 'coffee', 'concat' ]
				
		stylus:
			compile:
   			 	files:
   			 		'css/scaffold.source.css' : 'css/scaffold.styl'
					# 'css/admin.css' : 'css/admin.styl'

		coffee:
			compile:
				files:
					'js/app.source.js' 	: 'js/app.source.coffee'
					'js/horizontal.slider.js' 	: 'js/horizontal.slider.coffee'

		csslint: 
			lax: 
				options: 
					import: false
				src: ['css/*.css']

		cssmin:
			dist: 
				# src: [ 'css/utility/normalize.css',
				# 'css/utility/boxmodel.css',
				# 'css/structure.dev.css'
				# ]
				src: [ 'css/scaffold.source.css' ] 
				dest: 'css/compiled.development.css'
				
		concat:
			dist:
				dest: 'js/compiled.development.js'
				src: [
					"js/vendor/jquery-2.0.3.min.js"
					"js/vendor/verge.min.js"
					"js/vendor/jquery.velocity.min.js"
					"js/vendor/fastclick.js"
					"js/vendor/bowser.js"
					"js/vendor/underscore-min.js"
					'js/horizontal.slider.js' 
					]
		uglify:
			build:
				src: 'js/compiled.development.js'
				dest: 'js/compiled.build.js'

		
		
	grunt.initConfig config

	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-concat'
	grunt.loadNpmTasks 'grunt-contrib-uglify'
	grunt.loadNpmTasks 'grunt-contrib-stylus'
	grunt.loadNpmTasks 'grunt-contrib-cssmin'
	grunt.loadNpmTasks 'grunt-contrib-csslint'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-ftp-deploy'

