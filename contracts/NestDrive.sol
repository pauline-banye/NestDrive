//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";

contract NESTDRIVE {
    constructor() {}

    using Counters for Counters.Counter;

    ///total number of items ever created
    Counters.Counter private _itemIds;

    ///total number of items made private
    Counters.Counter private _itemsPrivate;

    event FileUploaded(
        uint fileId,
        string fileHash,
        uint fileSize,
        string fileType,
        string fileName,
        string fileDescription,
        uint uploadTime,
        address uploader,
        bool isPublic
    );

    struct File {
        uint fileId;
        string fileHash;
        string fileSize;
        string fileType;
        string fileName;
        string fileDescription;
        uint uploadTime;
        address uploader;
        bool isPublic;
    }

    mapping(uint => File) public Allfiles;

    function uploadFile(
        string memory _fileHash,
        uint _fileSize,
        string memory _fileType,
        string memory _fileName,
        string memory _fileDescription
    ) public {
        // Make sure the file hash exists
        require(bytes(_fileHash).length > 0);
        // Make sure file type exists
        require(bytes(_fileType).length > 0);
        // Make sure file description exists
        require(bytes(_fileDescription).length > 0);
        // Make sure file fileName exists
        require(bytes(_fileName).length > 0);
        // Make sure uploader address exists
        require(msg.sender != address(0));
        // Make sure file size is more than 0
        require(bytes(_fileSize).length > 0);

        // Increment file id
        _itemIds.increment();
        uint currentfileId = _itemIds.current();
        // Add File to the contract
        Allfiles[currentfileId] = File(
            currentfileId,
            _fileHash,
            _fileSize,
            _fileType,
            _fileName,
            _fileDescription,
            block.timestamp,
            msg.sender,
            true
        );
        // Trigger an event
        emit FileUploaded(
            currentfileId,
            _fileHash,
            _fileSize,
            _fileType,
            _fileName,
            _fileDescription,
            block.timestamp,
            msg.sender,
            true
        );
    }

    function makeFilePrivate(uint fileId) public {
        require(
            Allfiles[fileId].uploader == msg.sender,
            "you can only manipulate your own file"
        );

        Allfiles[fileId].isPublic = false;

        _itemsPrivate.increment();
    }

    function fetchPublicFiles() public view returns (File[] memory) {
        /// total number of items ever created
        uint totalFiles = _itemIds.current();

        uint publicFilesID = _itemIds.current() - _itemsPrivate.current();
        uint currentIndex = 0;

        File[] memory items = new File[](publicFilesID);

        ///loop through all items ever created
        for (uint i = 0; i < totalFiles; i++) {
            ///get only public item
            if (Allfiles[i + 1].isPublic == true) {
                uint currentId = Allfiles[i + 1].fileId;
                File storage currentItem = Allfiles[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }

        return items;
    }

    function fetchUserFiles() public view returns (File[] memory) {
        uint totalFiles = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        for (uint i = 0; i < totalFiles; i++) {
            if (Allfiles[i + 1].uploader == msg.sender) {
                itemCount += 1;
            }
        }
        File[] memory items = new File[](itemCount);
        for (uint i = 0; i < totalFiles; i++) {
            if (Allfiles[i + 1].uploader == msg.sender) {
                uint currentId = Allfiles[i + 1].fileId;
                File storage currentItem = Allfiles[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}
