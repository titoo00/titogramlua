package = "titogramlua"
version = "3.7-0"
source = {
    url = "https://github.com/titoo00/titogramlua/archive/refs/tags/v3.7.tar.gz",
    dir = "titogramlua-3.7"
}
description = {
    summary = "A feature-filled Telegram bot API library",
    detailed = "A feature-filled Telegram bot API library written in Lua, with Bot API 10.1 support.",
    homepage = "https://github.com/titoo00/titogramlua",
    maintainer = "Yousef Hesham <linkedin.com/in/yosef-hesham-485ab0440>",
    license = "GPL-3"
}
supported_platforms = {
    "linux",
    "macosx",
    "unix",
    "bsd"
}
dependencies = {
    "lua >= 5.1",
    "dkjson >= 2.5-2",
    "luasec >= 0.6-1",
    "luasocket >= 3.0rc1-2",
    "multipart-post >= 1.1-1",
    "luautf8 >= 0.1.1-1",
    "copas >= 4.0"
}
build = {
    type = "builtin",
    modules = {
        ["titogramlua"] = "src/main.lua",
        ["titogramlua.config"] = "src/config.lua",
        ["titogramlua.log"] = "src/log.lua",
        ["titogramlua.middleware"] = "src/middleware.lua",
        ["titogramlua.handlers"] = "src/handlers.lua",
        ["titogramlua.builders"] = "src/builders.lua",
        ["titogramlua.builders_rich"] = "src/builders_rich.lua",
        ["titogramlua.helpers"] = "src/helpers.lua",
        ["titogramlua.session"] = "src/session.lua",
        ["titogramlua.framework"] = "src/framework.lua",
        ["titogramlua.tools"] = "src/tools.lua",
        ["titogramlua.utils"] = "src/utils.lua",
        ["titogramlua.mcp"] = "src/mcp.lua",
        ["titogramlua.compat"] = "src/compat.lua",
        ["titogramlua.core"] = "src/core.lua",
        ["titogramlua.polyfill"] = "src/polyfill.lua",
        ["titogramlua.async"] = "src/async.lua",
        ["titogramlua.methods.userbot"] = "src/methods/userbot.lua",
        ["titogramlua.methods.userbot.send"] = "src/methods/userbot/send.lua",
        ["titogramlua.methods.userbot.execute"] = "src/methods/userbot/execute.lua",
        ["titogramlua.methods.userbot.receive"] = "src/methods/userbot/receive.lua",
        ["titogramlua.methods.userbot.run"] = "src/methods/userbot/run.lua",
        ["titogramlua.methods.userbot.stop"] = "src/methods/userbot/stop.lua",
        ["titogramlua.methods.userbot.close"] = "src/methods/userbot/close.lua",
        ["titogramlua.methods.userbot.send_message"] = "src/methods/userbot/send_message.lua",
        ["titogramlua.methods.userbot.send_photo"] = "src/methods/userbot/send_photo.lua",
        ["titogramlua.methods.userbot.edit_message_text"] = "src/methods/userbot/edit_message_text.lua",
        ["titogramlua.methods.userbot.delete_messages"] = "src/methods/userbot/delete_messages.lua",
        ["titogramlua.methods.userbot.get_chat"] = "src/methods/userbot/get_chat.lua",
        ["titogramlua.methods.userbot.get_chats"] = "src/methods/userbot/get_chats.lua",
        ["titogramlua.methods.userbot.get_message"] = "src/methods/userbot/get_message.lua",
        ["titogramlua.methods.userbot.get_messages"] = "src/methods/userbot/get_messages.lua",
        ["titogramlua.methods.userbot.search_messages"] = "src/methods/userbot/search_messages.lua",
        ["titogramlua.methods.userbot.upload_story"] = "src/methods/userbot/upload_story.lua",
        ["titogramlua.methods.userbot.get_story"] = "src/methods/userbot/get_story.lua",
        ["titogramlua.methods.userbot.get_chat_active_stories"] = "src/methods/userbot/get_chat_active_stories.lua",
        ["titogramlua.methods.userbot.delete_story"] = "src/methods/userbot/delete_story.lua",
        ["titogramlua.webhook"] = "src/webhook.lua",
        ["titogramlua.b64url"] = "src/b64url.lua",
        ["titogramlua.methods.updates"] = "src/methods/updates.lua",
        ["titogramlua.methods.messages"] = "src/methods/messages.lua",
        ["titogramlua.methods.chat"] = "src/methods/chat.lua",
        ["titogramlua.methods.members"] = "src/methods/members.lua",
        ["titogramlua.methods.forum"] = "src/methods/forum.lua",
        ["titogramlua.methods.stickers"] = "src/methods/stickers.lua",
        ["titogramlua.methods.inline"] = "src/methods/inline.lua",
        ["titogramlua.methods.payments"] = "src/methods/payments.lua",
        ["titogramlua.methods.games"] = "src/methods/games.lua",
        ["titogramlua.methods.passport"] = "src/methods/passport.lua",
        ["titogramlua.methods.bot"] = "src/methods/bot.lua",
        ["titogramlua.methods.gifts"] = "src/methods/gifts.lua",
        ["titogramlua.methods.checklists"] = "src/methods/checklists.lua",
        ["titogramlua.methods.stories"] = "src/methods/stories.lua",
        ["titogramlua.methods.business"] = "src/methods/business.lua",
        ["titogramlua.methods.suggested_posts"] = "src/methods/suggested_posts.lua",
        ["titogramlua.methods.rich"] = "src/methods/rich.lua",
        ["titogramlua.adapters"] = "src/adapters/init.lua",
        ["titogramlua.adapters.db"] = "src/adapters/db.lua",
        ["titogramlua.adapters.redis"] = "src/adapters/redis.lua",
        ["titogramlua.adapters.llm"] = "src/adapters/llm.lua",
        ["titogramlua.adapters.email"] = "src/adapters/email.lua"
    },
    install = {
        bin = {
            tgbot = "bin/tgbot"
        }
    }
}

