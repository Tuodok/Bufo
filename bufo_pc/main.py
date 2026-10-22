import asyncio
from event_manager import EventManager

if __name__ == '__main__':
    event_manager = EventManager()
    asyncio.run(event_manager.run())