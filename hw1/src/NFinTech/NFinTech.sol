// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
}

interface IERC721TokenReceiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4);
}

contract NFinTech is IERC721 {
    // Note: I have declared all variables you need to complete this challenge
    string private _name;
    string private _symbol;

    uint256 private _tokenId;

    mapping(uint256 => address) private _owner;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApproval;
    mapping(address => bool) private isClaim;
    mapping(address => mapping(address => bool)) _operatorApproval;

    error ZeroAddress();

    constructor(string memory name_, string memory symbol_) payable {
        _name = name_;
        _symbol = symbol_;
    }

    function claim() public {
        if (isClaim[msg.sender] == false) {
            uint256 id = _tokenId;
            _owner[id] = msg.sender;

            _balances[msg.sender] += 1;
            isClaim[msg.sender] = true;

            _tokenId += 1;
        }
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function balanceOf(address owner) public view returns (uint256) {
        if (owner == address(0)) revert ZeroAddress();
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owner[tokenId];
        if (owner == address(0)) revert ZeroAddress();
        return owner;
    }

    function setApprovalForAll(address operator, bool approved) external {
        require (operator != address(0));
        _operatorApproval[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApproval[owner][operator];
    }

    function approve(address to, uint256 tokenId) external {
        require(msg.sender == _owner[tokenId] || _operatorApproval[_owner[tokenId]][msg.sender] == true);
        _tokenApproval[tokenId] = to;
        emit Approval(_owner[tokenId], to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address operator) {
        return _tokenApproval[tokenId];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require (_owner[tokenId] == from && (msg.sender == from || _tokenApproval[tokenId] == msg.sender || _operatorApproval[from][msg.sender]));
        require (to != address(0));
        _owner[tokenId] = to;
        _balances[from]--;
        _balances[to]++;
        emit Transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        transferFrom(from, to, tokenId);
        require(IERC721TokenReceiver(to).onERC721Received(msg.sender, from, tokenId, data) == IERC721TokenReceiver.onERC721Received.selector);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }
}
