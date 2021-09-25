import discord
import requests
import argparse
import random
import time
import json
import re

class MyClient(discord.Client):
    async def on_connect(self):
        self.cardSearchPattern = re.compile("\[\[(.+?)\]\]")
        self.highTideCounter =  0
        self.primerCounter = 0

    async def on_ready(self):
        print('Logged on as', self.user)

    async def findMatches(self, card):
        if card.find("=") >= 0:
            return "Oops, that could get me in trouble. I won't search for %s." % (card)
        url = "https://api.scryfall.com/cards/search"
        params = {
            "q" : card
            }

        try:
            r = requests.get(url, params=params)
            result = json.loads( r.text )
        except:
            return "The archives are forbidden right now. <@236607188720680960> will be notified."

        if "total_cards" not in result.keys():
            return "\"%s\"? I got no info on that." % (card)

        if result["total_cards"] <= 3:
            message = "I found this in the archives:\n"
            for card in result["data"]:
                message += card["image_uris"]["normal"] + "\n"
            return message

        if result["total_cards"] > 3:
            return "\"%s\"?\nI fear you seek too much knowledge for your rank. Ask only for what you need." % (card)

    async def on_message(self, message):
        # don't respond to ourselves
        print( "Message: ", message )
        if message.author == self.user:
            return

        elif message.type == discord.MessageType.new_member:
            greetings = [
                "Welcome, %s, to the Dimir Public Offices. Not responsible for death or loss of property. Basement off-limits.",
                "May your tides be high, %s.",
                "You come looking for consultation, %s?",
                "%s!? What a dramatic reversal.",
                "Hello, %s, and welcome to the circu-s",
		"Come, %s, peer through the depths to find consultation.",
		"Yag's will, but %s opponents won't."
                "Took you long, %s, we're expecting you.",
                "%s, ask the right questions in the right way and truth is inevitable.",
                "%s, you've found this place only because you were summoned. Pray you're worthy of the invitation.",
                "Welcome back %s. You may not remember last time."
            ]
            await message.channel.send( random.choice(greetings) % message.author.name )
            self.primer_count = 0
            return

        elif message.content.upper().find("CIRCU") >= 0:
            if ( ((message.content.upper().find("LIST") > 0) and (message.content.upper().find("UPDATED") > 0)) or (message.content.upper().find("PRIMER") > 0) ):
                if (time.time() - self.primerCounter) > 300:
                    self.primerCounter = time.time()
                    await message.channel.send("Currently, we have two contenders:\n<@281582410523738113>'s primer https://tappedout.net/mtg-decks/21-06-17-assuming-control/ that links his Doomsday and Consultation lists,\nand <@389364859650703360>'s https://www.moxfield.com/decks/5PGTOmfq5EKb1UGxEH5yAQ for extra fast combo.\n\nCurrently Consultation and fast combo are the most viable lists, but we encourage everybody to brew and discuss other archetypes.\nIf you're interested, we also have local experts on Doomsday ( <@763585145244221482>'s https://tappedout.net/mtg-decks/doomsday-cedh-circu-experimental/?cb=1602398796 ) and Budget ( <@236607188720680960>'s https://www.moxfield.com/decks/jv99u4-XPE-qyeNlMixHBA ) lists.")

        elif ((message.content.upper().find(" HT ") >= 0) or (message.content.upper().find("HIGH TIDE") >= 0)):
                if (time.time() - self.highTideCounter) > 300:
                    self.highTideCounter = time.time()
                    await message.channel.send('<@238297603446407169>')

        elif (message.content.upper().find("ZYDRATE") >= 0):
                repo = [
                "It's quick, it's clean, it's pure.",
                "It can change your life, rest assured.",
                "It's the 21st century cure.",
                "It is my job. . . To steal and rob.",
                "Sometimes, I wonder why I ever got in.",
                "And when the gun goes off, it sparks, and you're ready for surgery.",
                "Years roll by without you, Marni",
                "It's a thankless job, but somebody's got to do it"
                ]
                await message.channel.send(random.choice(repo))

        for card in self.cardSearchPattern.findall( message.content ):
            await message.channel.send( await self.findMatches( card ) )

parser = argparse.ArgumentParser()
parser.add_argument("token", type=str)

args = parser.parse_args()
client = MyClient( guild_subscriptions=True )
client.run(args.token)
