# Getlocal

A simple tool to help updating an xcode projects localizations useing the getlocalization.com API.

## Installation

Add this line to your application's Gemfile:

    gem 'getlocal'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install getlocal

## Usage

This tool should be called from the project folder that conatians your Base.lproj folder.
To upload all your strings files to getlocalization.com

    $ getLocal update myproject -u me@example.com

To download all the translation files

    $ getLocal update myproject -u me@example.com

I've written this to work with the folder structure that I use for all my projects. If you have a different folder structure this may not work for you.
It assumes your project looks a little like this:

    - myProject.xcodeproj
    - project_folder // Call get local from here
        - Base.lproj
            - Localizable.strings // This is your master copy
            - Storyboard.storyboard
            - Storyboard.strings  // and so is this
        - en.lproj
            - Localizable.strings
            - Storyboard.strings
            
## Contributing

1. Fork it ( https://github.com/BenjaminBriggs/getlocal/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
