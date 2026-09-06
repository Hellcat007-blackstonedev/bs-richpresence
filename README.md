# bs-richpresence
A FiveM server RichPresence for Discord

![Screenshot of the rich presence](https://imgur.com/a/hWJS9jF)

## Installation
1. Drop this script into your resources folder.
2. Add `ensure bs-richpresence` to your `server.cfg`.
3. Restart your server.

## Configuration
- The config.lua file include commented explanations of each config option.  
- Inside the config file also has toggleable data that gets displayed in your RichPresence.  

> [!TIP]
> Be aware also that Discord buttons are not viewable to your own account displaying the RichPresence. If you like to see if your buttons are in fact working, you either need an alt account or get your friend to join your server and then you'll see the buttons. I don't know why Discord has set it up this way.

## Optional Discord Developer Application
If you'd like your RichPresence to have your server's logo and Server name implemented, go to the [Discord Developer Portal](https://discord.com/developers/home) and create a new app. From there, copy your application ID and replace the 'XXXXXXXXXXXXXXXXX' in the config.  
Next, go to the Rich Presence side menu open click on Art Assets then upload your server logo and add the asset key name to `Config.AssetName`.

## Need help?
You can join our development Discord here: https://discord.gg/dw5KbvB9MJ