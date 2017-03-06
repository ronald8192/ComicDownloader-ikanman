# Comic Downloader (ikanman)

Comic Downloader for ikanman.com

:warning: :warning: The download part (`download.rb`) is not working anymore since ikanman add additional checking on server side. I might fix it if I have time. You can still use `main.js` to get the image url list. It downloaded to `download/chapters.json`.

## Download and Install dependencies
    git clone --depth 1 https://github.com/ronald8192/ComicDownloader-ikanman.git
    cd ComicDownloader-ikanman
    npm install
    npm install bluebird

## How to use

```
npm start {comicId}
# or
node main.js {comicId}

# after `main.js` finish, `download/chapters.json` should be created
# then start to download the images
# create file/directory with index number, easier to sort
./download.rb --name-with-index
```

File will save to `./download/comicId/`
 
## Tested in

    node 4.4.7
    npm  3.10.5
    ruby 2.3.0
    Ubuntu Linux 14

