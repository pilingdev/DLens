import yt_dlp

url = 'https://www.youtube.com/watch?v=V_Z8XoPVDBg&pp=ugUEEgJlbg%3D%3D'

yt_dlp.YoutubeDL().download([url])