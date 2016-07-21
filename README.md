# Comic Downloader (ikanman)

Comic Downloader for ikanman.com

## Download and Install dependencies
    git clone --depth 1 https://github.com/ronald8192/ComicDownloader-ikanman.git
    cd ComicDownloader-ikanman
    npm install

## How to use

```
npm start {comicId}
# or
node main.js {comicId}

# after `main.js` finish, `download/chapters.json` should be created
# then start to download the images
./download.rb
```

File will save to `./download/comicId/`
 
## Tested in

    node 4.4.7
    npm  3.10.5
    ruby 2.3.0
    Ubuntu Linux 14

