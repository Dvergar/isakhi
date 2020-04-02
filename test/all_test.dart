import 'package:isakhi/entity_manager.dart';
import 'package:test/test.dart';

void main() {
  test('getComponent returns proper component', () {
    var em = EntityManager();
    var entity = em.createEntity();
    var pos = PositionComponent(2, 4);
    em.addComponent(entity, pos);
    PositionComponent pos2 = em.getComponent(entity, PositionComponent);

    expect(pos2.x, equals(pos.x));
    expect(pos2.y, equals(pos.y));
  });

  test('Adds', () {
    var em = EntityManager();
    var entitySet = em.getEntitySet([PositionComponent, NameComponent]);
    var entity = em.createEntity();
    var pos = PositionComponent(2, 4);
    em.addComponent(entity, pos);

    entitySet.applyChanges();

    expect(entitySet.adds.length, equals(1));
  });

  test('Changes', () {
    var em = EntityManager();
    var entitySet = em.getEntitySet([PositionComponent]);
    var entity = em.createEntity();
    var pos = PositionComponent(1, 2);
    em.addComponent(entity, pos);

    pos.x = 12;
    em.markChanged(entity, pos);

    entitySet.applyChanges();

    expect(entitySet.changes.length, equals(1));
  });

  test('Removes', () {
    var em = EntityManager();
    var entitySet = em.getEntitySet([PositionComponent]);
    var entity = em.createEntity();
    var pos = PositionComponent(1, 2);
    em.addComponent(entity, pos);
    em.removeComponent(entity, PositionComponent);

    entitySet.applyChanges();

    expect(entitySet.removes.length, equals(1));
  });

  test('DestroyEntity', () {
    var em = EntityManager();
    var entity = em.createEntity();
    var entitySet = em.getEntitySet([PositionComponent]);
    var entitySet2 = em.getEntitySet([PositionComponent, NameComponent]);
    var pos = PositionComponent(1, 2);
    em.addComponent(entity, pos);
    em.destroyEntity(entity);

    entitySet.applyChanges();
    entitySet2.applyChanges();

    expect(entitySet.removes.length, 1);
    expect(entitySet2.removes.length, 1);
  });

  test('EntitySet should grab all the entities if entities already exists', () {
    var em = EntityManager();
    var entity = em.createEntity();
    var pos = PositionComponent(1, 2);
    em.addComponent(entity, pos);

    var entitySet = em.getEntitySet([PositionComponent]);
    entitySet.applyChanges();

    expect(entitySet.adds.length, 1);
  });

  // SYSTEM BEHAVIOUR
  var em = EntityManager();
  var positionSystem = PositionSystem(em);
  var entity = em.createEntity();
  var pos = PositionComponent(1, 2);

  em.addComponent(entity, pos);
  pos.x = 5;
  em.markChanged(entity, pos);
  em.destroyEntity(entity);

  positionSystem.positionEntitySet.applyChanges();
  positionSystem.loop();
}

class PositionComponent implements Component {
  int x;
  int y;

  PositionComponent(this.x, this.y);
}

class NameComponent implements Component {
  String text;

  NameComponent(this.text);
}

class PositionSystem {
  EntitySet positionEntitySet;
  EntityManager em;

  PositionSystem(EntityManager em) {
    this.positionEntitySet =
        em.getEntitySet([PositionComponent, NameComponent]);
  }

  loop() {
    test('System entitysets behaviour', () {
      expect(positionEntitySet.adds.length, 1);
      expect(positionEntitySet.changes.length, 1);
      expect(positionEntitySet.removes.length, 1);
    });
  }
}
