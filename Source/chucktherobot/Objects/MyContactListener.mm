#import "MyContactListener.h"
#import "Object.h"

MyContactListener::MyContactListener() : _contacts() {
}

MyContactListener::~MyContactListener() {
}

void MyContactListener::BeginContact(b2Contact* contact) {
    // We need to copy out the data because the b2Contact passed in
    // is reused.
    MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    _contacts.push_back(myContact);
}

void MyContactListener::EndContact(b2Contact* contact) {
    MyContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<MyContact>::iterator pos;
    pos = std::find(_contacts.begin(), _contacts.end(), myContact);
    if (pos != _contacts.end()) {
        _contacts.erase(pos);
    }
}

void MyContactListener::PreSolve(b2Contact* contact,
								 const b2Manifold* oldManifold) {
}

void MyContactListener::PostSolve(b2Contact* contact,
								  const b2ContactImpulse* impulse)
{
	if (contact->GetFixtureA()->GetUserData() != NULL && contact->GetFixtureB()->GetUserData() != NULL)
	{
		int32 count = contact->GetManifold()->pointCount;
		
		float maxImpulse = 0.0f;
		
		for (int i = 0; i < count; i++)
		{
			maxImpulse = b2Max(maxImpulse, impulse->normalImpulses[i]);
		}
		
		if (((ObjectUserData *)contact->GetFixtureA()->GetUserData()))
		{
			Object *object1 = ((ObjectUserData *)contact->GetFixtureA()->GetUserData())->objectID;
			[object1 hitWithForce: maxImpulse];
		}
		
		if (((ObjectUserData *)contact->GetFixtureB()->GetUserData()))
		{
			Object *object2 = ((ObjectUserData *)contact->GetFixtureB()->GetUserData())->objectID;
			[object2 hitWithForce: maxImpulse];
		}
	}
}