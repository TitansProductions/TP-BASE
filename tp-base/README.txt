# How do i change Base UI locales?

- `tp-base > html > js > locales / locale`


# Where is the configuration file for the Base UI?

There are 2 configuration files, the default one and the one where you can change 
the discord url when clicking discord icon or changing the clicking sound volume which is config.js file.

1. `tp-base > config.lua`
2. `tp-base > html > js > config.js` 


# Why my reports or feedbacks does not store in the database (sql) ?

- Make sure you have imported the sql files in your database and then, if Config.USE_SQL_DATABASE is enabled (`true`) in the config.lua file.


# How do my players or myself change the avatar in the personal profile input?

- Make sure you have imported users.sql file and then in order to add an avatar image, the url must ending with the image type such as .png, .jpg 
like the default url example which is below:

https://i.imgur.com/xxxxxx.jpg <- (.jpg).

# Where do i change game commands & game keybinds text area?

- `tp-base > html > js > locales > locale file` (Locales.informationCommands & Locales.informationKeybinds).

(!) Use: \n to create in order to create a new line.


# How do i change Base UI logo?

- `tp-base > html > img > logo.png 

(!) Make sure your logo is having the same dimensions as the default logo (967 x 1178).
