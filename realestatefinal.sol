// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// Real estate program for buying and selling properties
contract RealEstatefinal {
    
    // Property struct to store information about a Property
    struct Property {
        uint256 price;
        address owner;
        bool forSale; // Indicates if the property is for sale or not
        string title;
        string description;
        string location;
        address nominee; // Nominee for the property
    }

    // Mapping from property IDs to Property structs
    mapping(uint256 => Property) public properties;

    // Array of all Property IDs
    uint256[] public propertyIds;

    // When a Property is sold
    event PropertySold(uint256 propertyId);

    // When a Property is listed for sale
    event PropertyListedForSale(uint256 propertyId, uint256 price);

    // Function to list a property for sale (by the owner)
    function listPropertyForSale(
        uint256 _propertyId,
        uint256 _price,
        string memory _title,
        string memory _description,
        string memory _location,
        address _nominee
    )
        public
    {
        // Ensure the sender is the owner or this is a new property (no owner set yet)
        require(msg.sender == properties[_propertyId].owner || properties[_propertyId].owner == address(0),
         "You are not the owner of this property");

        Property memory newProperty = Property({
            price: _price,
            owner: msg.sender,
            forSale: true,
            title: _title,
            description: _description,
            location: _location,
            nominee: _nominee
        });

        properties[_propertyId] = newProperty;
        propertyIds.push(_propertyId);

        // Emit the PropertyListedForSale event
        emit PropertyListedForSale(_propertyId, _price);
    }

    // Function to list a bought property for a new price (by the owner or nominee)
    function listBoughtPropertyForSale(uint256 _propertyId, uint256 _newPrice) public {
        Property storage property = properties[_propertyId];

        // Ensure the sender is either the owner or the nominee
        require(
            msg.sender == property.owner || msg.sender == property.nominee,
            "You are neither the owner nor the nominee of this property");

        property.price = _newPrice;
        property.forSale = true;

        // Emit the PropertyListedForSale event
        emit PropertyListedForSale(_propertyId, _newPrice);
    }

    // Function to buy a property and choose who to pay (owner or nominee)
    function buyPropertyWithRepayment(uint256 _propertyId, address _payee) public payable {
        Property storage property = properties[_propertyId];

        require(property.forSale, "Property is not for sale");
        require(property.price <= msg.value, "Insufficient balance");
        require(_payee == property.owner || _payee == property.nominee, "Payee must be the owner or nominee");

        // address previousOwner = property.owner;
        property.owner = msg.sender;
        property.forSale = false;
        property.nominee = address(0);  // Clear the nominee upon sale

        // Transfer the amount to the selected payee (either the owner or the nominee)
        payable(_payee).transfer(property.price);

        // Emit the PropertySold event
        emit PropertySold(_propertyId);
    }

    // Function to get the current owner of a property
    function getPropertyOwner(uint256 _propertyId) public view returns (address) {
        return properties[_propertyId].owner;
    }

    // Function to set a nominee for a property (only by the current owner)
    function setNominee(uint256 _propertyId, address _nominee) public {
        Property storage property = properties[_propertyId];

        // Ensure the sender is the owner
        require(msg.sender == property.owner, "You are not the owner of this property");

        property.nominee = _nominee;
    }

    // Function to remove the nominee from a property (only by the owner)
    function removeNominee(uint256 _propertyId) public {
        Property storage property = properties[_propertyId];

        // Ensure the sender is the owner
        require(msg.sender == property.owner, "You are not the owner of this property");

        property.nominee = address(0);
    }
}